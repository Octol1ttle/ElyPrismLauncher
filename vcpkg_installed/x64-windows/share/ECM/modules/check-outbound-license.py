#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2020 Andreas Cord-Landwehr <cordlandwehr@kde.org>
# SPDX-License-Identifier: BSD-3-Clause

# key    : outbound license identifier
# values : list of acceptable licenses that are compatible with outbound license
compatibilityMatrix = {
    "MIT": [
        "CC0-1.0",
        "MIT"],
    "BSD-2-Clause": [
        "CC0-1.0",
        "MIT",
        "BSD-2-Clause"],
    "BSD-3-Clause": [
        "CC0-1.0",
        "MIT",
        "BSD-2-Clause",
        "BSD-3-Clause"],
    "LGPL-2.0-only": [
        "CC0-1.0",
        "LGPL-2.0-only",
        "LGPL-2.0-or-later",
        "MIT",
        "BSD-2-Clause",
        "BSD-3-Clause",
        "bzip2-1.0.6"],
    "LGPL-2.1-only": [
        "CC0-1.0",
        "LGPL-2.0-or-later",
        "LGPL-2.1-only",
        "LGPL-2.1-or-later",
        "MIT",
        "BSD-2-Clause",
        "BSD-3-Clause",
        "bzip2-1.0.6"],
    "LGPL-3.0-only": [
        "CC0-1.0",
        "LGPL-2.0-or-later",
        "LGPL-2.1-or-later",
        "LGPL-3.0-only",
        "LGPL-3.0-or-later",
        "LicenseRef-KDE-Accepted-LGPL",
        "MIT",
        "BSD-2-Clause",
        "BSD-3-Clause",
        "bzip2-1.0.6"],
    "GPL-2.0-only": [
        "CC0-1.0",
        "LGPL-2.0-only",
        "LGPL-2.1-only",
        "LGPL-2.0-or-later",
        "LGPL-2.1-or-later",
        "GPL-2.0-only",
        "GPL-2.0-or-later",
        "MIT",
        "BSD-2-Clause",
        "BSD-3-Clause",
        "bzip2-1.0.6"],
    "GPL-3.0-only": [
        "CC0-1.0",
        "LGPL-2.0-or-later",
        "LGPL-2.1-or-later",
        "LGPL-3.0-only",
        "LGPL-3.0-or-later",
        "GPL-2.0-or-later",
        "GPL-3.0-only",
        "GPL-3.0-or-later",
        "LicenseRef-KDE-Accepted-GPL",
        "LicenseRef-KDE-Accepted-LGPL",
        "MIT",
        "BSD-2-Clause",
        "BSD-3-Clause",
        "bzip2-1.0.6"]
}

def check_outbound_license(license, files, spdxDictionary):
    """
    Asserts that the list of source files @p files, when combined into
    a library or executable, can be delivered under the combined license @p license .
    """
    print("Checking Target License: " + license)
    if not license in compatibilityMatrix:
        print("Error: unknown license selected")
        return False

    allLicensesAreCompatible = True

    for sourceFile in files:
        compatible = False
        sourceFileStripped = sourceFile.strip()
        for fileLicense in spdxDictionary[sourceFileStripped]:
            if fileLicense in compatibilityMatrix[license]:
                compatible = True
                print("OK " + sourceFileStripped + " : " + fileLicense)
        if not compatible:
            allLicensesAreCompatible = False
            print("-- " + sourceFileStripped + " : ( " + ", ".join([str(i) for i in spdxDictionary[sourceFileStripped]]) + " )")
    return allLicensesAreCompatible

if __name__ == '__main__':
    print("Parsing SPDX BOM file")
    import sys
    import argparse

    # parse commands
    parser = argparse.ArgumentParser()
    parser.add_argument("-l", "--license", help="set outbound license to test")
    parser.add_argument("-s", "--spdx", help="spdx bill-of-materials file")
    parser.add_argument("-i", "--input", help="input file with list of source files to test")
    args = parser.parse_args()

    # TODO check if required arguments are present and give meaningful feedback

    # collect name and licenses from SPDX blocks
    spdxDictionary = {}
    fileName = ""
    licenses = []
    f = open(args.spdx, "r")
    for line in f:
        if line.startswith("FileName:"):
            # strip "FileName: "
            # thus name expected to start with "./", which is relative to CMAKE_SOURCE_DIR
            fileName = line[10:].strip()
        if line.startswith("LicenseInfoInFile:"):
            licenses.append(line[19:].strip())
        if line == '' or line == "\n":
            spdxDictionary[fileName] = licenses
            fileName = ""
            licenses = []
    f.close()

    spdxDictionary[fileName] = licenses

    # read file with list of test files
    f = open(args.input, "r")
    testfiles = f.readlines()
    f.close()

    if check_outbound_license(args.license, testfiles, spdxDictionary) is True:
        sys.exit(0)

    # in any other case, return error code
    sys.exit(1)
