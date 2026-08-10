> [!CAUTION]
> **There's now malicious links in the wild that disguise themselves as this project.**
>
> Make sure that you download PineconeMC from `elyprismlauncher.github.io` and/or `pineconemc.ru`.

<p align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="/program_info/ru.pineconemc.launcher.logo-darkmode.svg">
  <source media="(prefers-color-scheme: light)" srcset="/program_info/ru.pineconemc.launcher.logo.svg">
  <img alt="ru.pineconemc.launcher" src="/program_info/ru.pineconemc.launcher.logo.svg" width="40%">
</picture>
</p>

<p align="center">
  This <b>fork</b> of Prism Launcher adds integrated support for Ely.by accounts (MSA accounts can still be used)<br />
  <br />This is <b>not</b> endorsed by Prism Launcher or Ely.by.
</p>

## Why this fork?

There are already quite a few forks out in the wild that add Ely.by support and/or disable the Microsoft account requirement. This fork goes beyond simply adding a login-password prompt and authlib-injector download.

- Modern and secure login: PineconeMC uses OAuth2 to log you in. This means that your credentials are never transferred to the launcher. Instead, you log into your account on the official Ely.by page in the browser, and Ely.by gives the launcher a token to access your account with limited privileges.
- Skins support on servers: All other forks rely exclusively on authlib-injector to patch Minecraft to support Ely.by. But authlib-injector can't provide skins on servers that don't have a special skins plugin installed. PineconeMC uses Ely.by's official Authlib patches, allowing you to see skins anywhere

## Multiple launches of one instance

PineconeMC can run multiple independent Minecraft processes from the same instance at the same time. The **Launch** action remains available while that instance is running.

- Each launch has its own lifecycle and selectable console log.
- The instance window can stop the currently selected launch session.
- Play time is measured as wall-clock time while at least one Minecraft process is running, so parallel sessions do not multiply it.
- Starting another process displays a warning because all sessions share the same game directory, configuration, saves, and log files. The warning can be disabled with **Don't show this warning again**.

Running multiple processes against one game directory can cause conflicting writes or data loss. Use this feature only when the selected Minecraft versions and mods can safely share those files.

## Installation

- All downloads and instructions for PineconeMC can be found on the [Releases](https://github.com/ElyPrismLauncher/Launcher/releases/latest) page.
- Last build status can be found in the [GitHub Actions](https://github.com/ElyPrismLauncher/Launcher/actions) tab.

### Development Builds

Please understand that these builds are not intended for most users. There may be bugs, and other instabilities. You have been warned.

There are development builds available through:

- [GitHub Actions](https://github.com/ElyPrismLauncher/Launcher/actions) (includes builds from pull requests opened by contributors)
- [nightly.link](https://nightly.link/ElyPrismLauncher/Launcher/workflows/build/develop) (this will always point only to the latest version of develop)

These have debug information in the binaries, so their file sizes are relatively larger.

## Community & Support

Feel free to create a GitHub issue if you find a bug or want to suggest a new feature. We have a Discord server where other community members can help you:

[![Octol1ttle's Studio Discord server](https://discordapp.com/api/guilds/1201522867901313045/widget.png?style=banner3)](https://discord.gg/5kcBCvnbTp)

## Building

If you want to build PineconeMC yourself, check the [build instructions](https://prismlauncher.org/wiki/development/build-instructions).

## The following comes from the original Prism Launcher README

### Forking/Redistributing/Custom builds policy

You are free to fork, redistribute and provide custom builds as long as you follow the terms of the [license](LICENSE) (this is a legal responsibility), and if you made code changes rather than just packaging a custom build, please do the following as a basic courtesy:

- Make it clear that your fork is not Prism Launcher and is not endorsed by or affiliated with the Prism Launcher project (<https://prismlauncher.org>).
- Go through [CMakeLists.txt](CMakeLists.txt) and change Prism Launcher's API keys to your own or set them to empty strings (`""`) to disable them (this way the program will still compile but the functionality requiring those keys will be disabled).

If you have any questions or want any clarification on the above conditions please make an issue and ask us.

If you are just building Prism Launcher for your distribution, please make sure to set the `Launcher_BUILD_PLATFORM` to a slug representing your distribution. Examples are `archlinux`, `fedora` and `nixpkgs`.

Note that if you build this software without removing the provided API keys in [CMakeLists.txt](CMakeLists.txt) you are accepting the following terms and conditions:

- [Microsoft Identity Platform Terms of Use](https://docs.microsoft.com/en-us/legal/microsoft-identity-platform/terms-of-use)
- [CurseForge 3rd Party API Terms and Conditions](https://support.curseforge.com/en/support/solutions/articles/9000207405-curse-forge-3rd-party-api-terms-and-conditions)

If you do not agree with these terms and conditions, then remove the associated API keys from the [CMakeLists.txt](CMakeLists.txt) file by setting them to an empty string (`""`).

### License [![https://github.com/PrismLauncher/PrismLauncher/blob/develop/LICENSE](https://img.shields.io/github/license/PrismLauncher/PrismLauncher?label=License&logo=gnu&color=C4282D)](LICENSE)

All launcher code is available under the GPL-3.0-only license.

The logo and related assets are under the CC BY-SA 4.0 license.
