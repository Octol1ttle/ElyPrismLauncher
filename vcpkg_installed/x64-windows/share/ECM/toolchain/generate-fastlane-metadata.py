#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: 2018-2020 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-FileCopyrightText: 2019-2020 Ben Cooksley <bcooksley@kde.org>
# SPDX-FileCopyrightText: 2020 Volker Krause <vkrause@kde.org>
#
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Generates fastlane metadata for Android apps from appstream files.
#

import argparse
import glob
import io
import os
import re
import requests
import shutil
import subprocess
import sys
import tempfile
import xdg.DesktopEntry
import xml.etree.ElementTree as ET
import yaml
import zipfile

# Constants used in this script
# map KDE's translated language codes to those expected by Android
# see https://f-droid.org/en/docs/Translation_and_Localization/
# F-Droid is more tolerant than the Play Store here, the latter rejects anything not exactly matching its known codes
# Android does do the expected fallbacks, so the seemingly "too specific" mappings here are still working as expected
# see https://developer.android.com/guide/topics/resources/multilingual-support#resource-resolution-examples
# The following is the list of languages/translations that can be selected on the page "Main store listing" under
# "Store presence" of Google Play Console (as of 2024-03-15).
# Afrikaans – af
# Albanian – sq
# Amharic – am
# Arabic – ar
# Armenian – hy-AM
# Azerbaijani – az-AZ
# Bangla – bn-BD
# Basque – eu-ES
# Belarusian – be
# Bulgarian – bg
# Burmese – my-MM
# Catalan – ca
# Chinese (Hong Kong) – zh-HK
# Chinese (Simplified) – zh-CN
# Chinese (Traditional) – zh-TW
# Croatian – hr
# Czech – cs-CZ
# Danish – da-DK
# Dutch – nl-NL
# English (Australia) – en-AU
# English (Canada) – en-CA
# English (United Kingdom) – en-GB
# English – en-IN
# English – en-SG
# English – en-ZA
# Estonian – et
# Filipino – fil
# Finnish – fi-FI
# French (Canada) – fr-CA
# French (France) – fr-FR
# Galician – gl-ES
# Georgian – ka-GE
# German – de-DE
# Greek – el-GR
# Gujarati – gu
# Hebrew – iw-IL
# Hindi – hi-IN
# Hungarian – hu-HU
# Icelandic – is-IS
# Indonesian – id
# Italian – it-IT
# Japanese – ja-JP
# Kannada – kn-IN
# Kazakh – kk
# Khmer – km-KH
# Korean – ko-KR
# Kyrgyz – ky-KG
# Lao – lo-LA
# Latvian – lv
# Lithuanian – lt
# Macedonian – mk-MK
# Malay (Malaysia) – ms-MY
# Malay – ms
# Malayalam – ml-IN
# Marathi – mr-IN
# Mongolian – mn-MN
# Nepali – ne-NP
# Norwegian – no-NO
# Persian – fa
# Persian – fa-AE
# Persian – fa-AF
# Persian – fa-IR
# Polish – pl-PL
# Portuguese (Brazil) – pt-BR
# Portuguese (Portugal) – pt-PT
# Punjabi – pa
# Romanian – ro
# Romansh – rm
# Russian – ru-RU
# Serbian – sr
# Sinhala – si-LK
# Slovak – sk
# Slovenian – sl
# Spanish (Latin America) – es-419
# Spanish (Spain) – es-ES
# Spanish (United States) – es-US
# Swahili – sw
# Swedish – sv-SE
# Tamil – ta-IN
# Telugu – te-IN
# Thai – th
# Turkish – tr-TR
# Ukrainian – uk
# Urdu – ur
# Vietnamese – vi
# Zulu – zu
languageMap = {
    None: "en-US",
    "ast": None, # not supported by Google Play for meta data
    "ca-valencia": None, # not supported by Android
    "cs": "cs-CZ",
    "da": "da-DK",
    "de": "de-DE",
    "el": "el-GR",
    "eo": None, # neither supported by Android nor by Google Play for meta data
    "es": "es-ES",
    "eu": "eu-ES",
    "fi": "fi-FI",
    "fr": "fr-FR",
    "gl": "gl-ES",
    "ia": None, # not supported by Google Play for meta data
    "it": "it-IT",
    "ka": "ka-GE",
    "ko": "ko-KR",
    "nl": "nl-NL",
    "nn": "no-NO", # Google Play only supports no-NO (no = macrolanguage for nb/Bokmal and nn/Nynorsk)
    "pl": "pl-PL",
    "pt": "pt-PT",
    "ru": "ru-RU",
    "sr": "sr-Cyrl-RS",
    "sr@latin": "sr-Latn-RS",
    "sv": "sv-SE",
    "tr": "tr-TR",
    'x-test': None
}

# The subset of supported rich text tags in F-Droid and Google Play
# - see https://f-droid.org/en/docs/All_About_Descriptions_Graphics_and_Screenshots/ for F-Droid
# - Google Play doesn't support lists
supportedRichTextTags = { 'b', 'u', 'i' }

# List all translated languages present in an Appstream XML file
def listAllLanguages(root, langs):
    for elem in root:
        lang = elem.get('{http://www.w3.org/XML/1998/namespace}lang')
        if not lang in langs:
            langs.add(lang)
        listAllLanguages(elem, langs)

# Apply language fallback to a map of translations
def applyLanguageFallback(data, allLanguages):
    for l in allLanguages:
        if not l in data or not data[l] or len(data[l]) == 0:
            data[l] = data[None]

# Android appdata.xml textual item parser
# This function handles reading standard text entries within an Android appdata.xml file
# In particular, it handles splitting out the various translations, and converts some HTML to something which F-Droid can make use of
# We have to handle incomplete translations both on top-level and intermediate tags,
# and fall back to the English default text where necessary.
def readText(elem, found, allLanguages):
    # Determine the language this entry is in
    lang = elem.get('{http://www.w3.org/XML/1998/namespace}lang')

    # Do we have any text for this language yet?
    # If not, get everything setup
    for l in allLanguages:
        if not l in found:
            found[l] = ""

    # If there is text available, we'll want to extract it
    # Additionally, if this element has any children, make sure we read those as well
    if elem.tag in supportedRichTextTags:
        if (elem.text and elem.text.strip()) or lang:
            found[lang] += '<' + elem.tag + '>'
        else:
            for l in allLanguages:
                found[l] += '<' + elem.tag + '>'
    elif elem.tag == 'li':
        found[lang] += '· '

    if elem.text and elem.text.strip():
        found[lang] += elem.text

    subOutput = {}
    for child in elem:
        if not child.get('{http://www.w3.org/XML/1998/namespace}lang') and len(subOutput) > 0:
            applyLanguageFallback(subOutput, allLanguages)
            for l in allLanguages:
                found[l] += subOutput[l]
            subOutput = {}
        readText(child, subOutput, allLanguages)
    if len(subOutput) > 0:
        applyLanguageFallback(subOutput, allLanguages)
        for l in allLanguages:
            found[l] += subOutput[l]

    if elem.tag in supportedRichTextTags:
        if (elem.text and elem.text.strip()) or lang:
            found[lang] += '</' + elem.tag + '>'
        else:
            for l in allLanguages:
                found[l] += '</' + elem.tag + '>'

    # Finally, if this element is a HTML Paragraph (p) or HTML List Item (li) make sure we add a new line for presentation purposes
    if elem.tag == 'li' or elem.tag == 'p':
        found[lang] += "\n"


# Create the various Fastlane format files per the information we've previously extracted
# These files are laid out following the Fastlane specification (links below)
# https://github.com/fastlane/fastlane/blob/2.28.7/supply/README.md#images-and-screenshots
# https://docs.fastlane.tools/actions/supply/
def createFastlaneFile( applicationName, filenameToPopulate, fileContent ):
    # Go through each language and content pair we've been given
    for lang, text in fileContent.items():
        # First, do we need to amend the language id, to turn the Android language ID into something more F-Droid/Fastlane friendly?
        languageCode = languageMap.get(lang, lang)
        if not languageCode:
            continue

        # Next we need to determine the path to the directory we're going to be writing the data into
        repositoryBasePath = arguments.output
        path = os.path.join( repositoryBasePath, 'metadata',  applicationName, languageCode )

        # Make sure the directory exists
        os.makedirs(path, exist_ok=True)

        # Now write out file contents!
        with open(path + '/' + filenameToPopulate, 'w') as f:
            f.write(text.strip()) # trim whitespaces, to avoid spurious differences after a Google Play roundtrip

# Create the summary appname.yml file used by F-Droid to summarise this particular entry in the repository
# see https://f-droid.org/en/docs/Build_Metadata_Reference/
def createYml(appname, data):
    # Prepare to retrieve the existing information
    info = {}

    # Determine the path to the appname.yml file
    repositoryBasePath = arguments.output
    path = os.path.join( repositoryBasePath, 'metadata', appname + '.yml' )

    # Update the categories first
    # Now is also a good time to add 'KDE' to the list of categories as well
    if 'categories' in data:
        info['Categories'] = data['categories'][None] + ['KDE']
    else:
        info['Categories']  = ['KDE']

    # Update the general summary as well
    info['Summary'] = data['summary'][None]

    # Check to see if we have a Homepage...
    if 'url-homepage' in data:
        info['WebSite'] = data['url-homepage'][None]

    # What about a bug tracker?
    if 'url-bugtracker' in data:
        info['IssueTracker'] = data['url-bugtracker'][None]

    if 'project_license' in data:
        info["License"] = data['project_license'][None]

    if 'source-repo' in data:
        info['SourceCode'] = data['source-repo']

    if 'url-donation' in data:
        info['Donate'] = data['url-donation'][None]
    else:
        info['Donate'] = 'https://kde.org/community/donations/'

    # static data
    info['Translation'] = 'https://l10n.kde.org/'

    # Finally, with our updates completed, we can save the updated appname.yml file back to disk
    with open(path, 'w') as output:
        yaml.dump(info, output, default_flow_style=False)

# Integrates locally existing image assets into the metadata
def processLocalImages(applicationName, data):
    if not os.path.exists(os.path.join(arguments.source, 'fastlane')):
        return

    outPath = os.path.abspath(arguments.output);
    oldcwd = os.getcwd()
    os.chdir(os.path.join(arguments.source, 'fastlane'))

    imageFiles = glob.glob('metadata/**/*.png', recursive=True)
    imageFiles.extend(glob.glob('metadata/**/*.jpg', recursive=True))
    for image in imageFiles:
        # noramlize single- vs multi-app layouts
        imageDestName = image.replace('metadata/android', 'metadata/' + applicationName)

        # copy image
        os.makedirs(os.path.dirname(os.path.join(outPath, imageDestName)), exist_ok=True)
        shutil.copy(image, os.path.join(outPath, imageDestName))

        # if the source already contains screenshots, those override whatever we found in the appstream file
        if 'phoneScreenshots' in image:
            data['screenshots'] = {}

    os.chdir(oldcwd)

# Attempt to find the application icon if we haven't gotten that explicitly from processLocalImages
def findIcon(applicationName, iconBaseName):
    iconPath = os.path.join(arguments.output, 'metadata', applicationName, 'en-US', 'images', 'icon.png')
    if os.path.exists(iconPath):
        return

    oldcwd = os.getcwd()
    os.chdir(arguments.source)

    iconFiles = glob.glob(f"**/{iconBaseName}-playstore.png", recursive=True)
    for icon in iconFiles:
        os.makedirs(os.path.dirname(iconPath), exist_ok=True)
        shutil.copy(icon, iconPath)
        break

    os.chdir(oldcwd)

# Download screenshots referenced in the appstream data
# see https://f-droid.org/en/docs/All_About_Descriptions_Graphics_and_Screenshots/
def downloadScreenshots(applicationName, data):
    if not 'screenshots' in data:
        return

    path = os.path.join(arguments.output, 'metadata',  applicationName, 'en-US', 'images', 'phoneScreenshots')
    os.makedirs(path, exist_ok=True)

    i = 1 # number screenshots starting at 1 rather than 0 to match what the fastlane tool does
    for screenshot in data['screenshots']:
        fileName = str(i) + '-' + screenshot[screenshot.rindex('/') + 1:]
        r = requests.get(screenshot)
        if r.status_code < 400:
            with open(os.path.join(path, fileName), 'wb') as f:
                f.write(r.content)
            i += 1

# Put all metadata for the given application name into an archive
# We need this to easily transfer the entire metadata to the signing machine for integration
# into the F-Droid nightly repository
def createMetadataArchive(applicationName):
    srcPath = os.path.join(arguments.output, 'metadata')
    zipFileName = os.path.join(srcPath, 'fastlane-' + applicationName + '.zip')
    if os.path.exists(zipFileName):
        os.unlink(zipFileName)
    archive = zipfile.ZipFile(zipFileName, 'w')
    archive.write(os.path.join(srcPath, applicationName + '.yml'), applicationName + '.yml')

    oldcwd = os.getcwd()
    os.chdir(srcPath)
    for file in glob.iglob(applicationName + '/**', recursive=True):
        archive.write(file, file)
    os.chdir(oldcwd)

# Generate metadata for the given appstream and desktop files
def processAppstreamFile(appstreamFileName, desktopFileName, iconBaseName):
    # appstreamFileName has the form <id>.appdata.xml or <id>.metainfo.xml, so we
    # have to strip off two extensions
    applicationName = os.path.splitext(os.path.splitext(os.path.basename(appstreamFileName))[0])[0]

    data = {}
    # Within this file we look at every entry, and where possible try to export it's content so we can use it later
    appstreamFile = open(appstreamFileName, "rb")
    root = ET.fromstring(appstreamFile.read())

    allLanguages = set()
    listAllLanguages(root, allLanguages)

    for child in root:
        # Make sure we start with a blank slate for this entry
        output = {}

        # Grab the name of this particular attribute we're looking at
        # Within the Fastlane specification, it is possible to have several items with the same name but as different types
        # We therefore include this within our extracted name for the attribute to differentiate them
        tag = child.tag
        if 'type' in child.attrib:
            tag += '-' + child.attrib['type']

        # Have we found some information already for this particular attribute?
        if tag in data:
            output = data[tag]

        # Are we dealing with category information here?
        # If so, then we need to look into this items children to find out all the categories this APK belongs in
        if tag == 'categories':
            cats = []
            for x in child:
                cats.append(x.text)
            output = { None: cats }

        # screenshot links
        elif tag == 'screenshots':
            output = []
            for screenshot in child:
                if screenshot.tag == 'screenshot':
                    for image in screenshot:
                        if image.tag == 'image':
                            output.append(image.text)

        # Otherwise this is just textual information we need to extract
        else:
            readText(child, output, allLanguages)

        # Save the information we've gathered!
        data[tag] = output

    applyLanguageFallback(data['name'], allLanguages)
    applyLanguageFallback(data['summary'], allLanguages)
    applyLanguageFallback(data['description'], allLanguages)

    # Did we find any categories?
    # Sometimes we don't find any within the Fastlane information, but without categories the F-Droid store isn't of much use
    # In the event this happens, fallback to the *.desktop file for the application to see if it can provide any insight.
    if not 'categories' in data and desktopFileName:
        # Parse the XDG format *.desktop file, and extract the categories within it
        desktopFile = xdg.DesktopEntry.DesktopEntry(desktopFileName)
        data['categories'] = { None: desktopFile.getCategories() }

    # Try to figure out the source repository
    if arguments.source and os.path.exists(os.path.join(arguments.source, '.git')):
        upstream_ref = subprocess.check_output(['git', 'rev-parse', '--symbolic-full-name', '@{u}'], cwd=arguments.source).decode('utf-8')
        remote = upstream_ref.split('/')[2]
        output = subprocess.check_output(['git', 'remote', 'get-url', remote], cwd=arguments.source).decode('utf-8')
        data['source-repo'] = output.strip()

    # write meta data
    createFastlaneFile( applicationName, "title.txt", data['name'] )
    createFastlaneFile( applicationName, "short_description.txt", data['summary'] )
    createFastlaneFile( applicationName, "full_description.txt", data['description'] )
    createYml(applicationName, data)

    # cleanup old image files before collecting new ones
    imagePath = os.path.join(arguments.output, 'metadata',  applicationName, 'en-US', 'images')
    shutil.rmtree(imagePath, ignore_errors=True)
    processLocalImages(applicationName, data)
    downloadScreenshots(applicationName, data)
    findIcon(applicationName, iconBaseName)

    # put the result in an archive file for easier use by Jenkins
    createMetadataArchive(applicationName)

# scan source directory for manifests/metadata we can work with
def scanSourceDir():
    files = glob.iglob(arguments.source + "/**/AndroidManifest.xml*", recursive=True)
    for file in files:
        # third-party libraries might contain AndroidManifests which we are not interested in
        if "3rdparty" in file:
            continue

        # find application id from manifest files
        root = ET.parse(file)
        appname = root.getroot().attrib['package']
        is_app = False
        prefix = '{http://schemas.android.com/apk/res/android}'
        for md in root.findall("application/activity/meta-data"):
            if md.attrib[prefix + 'name'] == 'android.app.lib_name':
                is_app = True

        if not appname or not is_app:
            continue

        iconBaseName = None
        for elem in root.findall('application'):
            if prefix + 'icon' in elem.attrib:
                iconBaseName = elem.attrib[prefix + 'icon'].split('/')[-1]

        # now that we have the app id, look for matching appdata/desktop files
        appdataFiles = glob.glob(arguments.source + "/**/" + appname + ".metainfo.xml", recursive=True)
        appdataFiles.extend(glob.glob(arguments.source + "/**/" + appname + ".appdata.xml", recursive=True))
        appdataFile = None
        for f in appdataFiles:
            appdataFile = f
            break
        if not appdataFile:
            continue

        desktopFiles = glob.iglob(arguments.source + "/**/" + appname + ".desktop", recursive=True)
        desktopFile = None
        for f in desktopFiles:
            desktopFile = f
            break

        processAppstreamFile(appdataFile, desktopFile, iconBaseName)


### Script Commences

# Parse the command line arguments we've been given
parser = argparse.ArgumentParser(description='Generate fastlane metadata for Android apps from appstream metadata')
parser.add_argument('--appstream', type=str, required=False, help='Appstream file to extract metadata from')
parser.add_argument('--desktop', type=str, required=False, help='Desktop file to extract additional metadata from')
parser.add_argument('--source', type=str, required=False, help='Source directory to find metadata in')
parser.add_argument('--output', type=str, required=True, help='Path to which the metadata output should be written to')
arguments = parser.parse_args()

# ensure the output path exists
os.makedirs(arguments.output, exist_ok=True)

# if we have an appstream file explicitly specified, let's use that one
if arguments.appstream and os.path.exists(arguments.appstream):
    processAppstreamFile(arguments.appstream, arguments.desktop)
    sys.exit(0)

# else, look in the source dir for appstream/desktop files
# this follows roughly what get-apk-args from binary factory does
if arguments.source and os.path.exists(arguments.source):
    scanSourceDir()
    sys.exit(0)

# else: missing arguments
print("Either one of --appstream or --source have to be provided!")
sys.exit(1)
