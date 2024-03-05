<p align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="/program_info/org.prismlauncher.PrismLauncher.logo-darkmode.svg">
  <source media="(prefers-color-scheme: light)" srcset="/program_info/org.prismlauncher.PrismLauncher.logo.svg">
  <img alt="Prism Launcher" src="/program_info/org.prismlauncher.PrismLauncher.logo.svg" width="40%">
</picture>
</p>

<p align="center">
  This <b>fork</b> of Prism Launcher replaces legacy Mojang accounts with Ely.by accounts<br />
  <br />This is <b>not</b> endorsed by Prism Launcher or Ely.by.
</p>

## Installation

- All downloads can be found [here](https://github.com/Octol1ttle/PrismLauncher-elyby/releases/latest).
- Last build status can be found in the [GitHub Actions](https://github.com/Octol1ttle/PrismLauncher-elyby/actions).

## Community & Support

Feel free to create a GitHub issue if you find a bug or want to suggest a new feature. We have a Discord server where other community members can help you:

[![Prism Launcher Discord server](https://discordapp.com/api/guilds/1201522867901313045/widget.png?style=banner3)](https://discord.gg/5kcBCvnbTp)

## Building

If you want to build Prism Launcher yourself, check the [Build Instructions](https://prismlauncher.org/wiki/development/build-instructions/).

## Sponsors & Partners

Thanks to JetBrains for providing us a few licenses for all their products, as part of their [Open Source program](https://www.jetbrains.com/opensource/).

[![JetBrains](https://resources.jetbrains.com/storage/products/company/brand/logos/jb_beam.svg)](https://www.jetbrains.com/opensource/)

## Forking/Redistributing/Custom builds policy

You are free to fork, redistribute and provide custom builds as long as you follow the terms of the [license](LICENSE) (this is a legal responsibility), and if you made code changes rather than just packaging a custom build, please do the following as a basic courtesy:

- Make it clear that your fork is not Prism Launcher and is not endorsed by or affiliated with the Prism Launcher project (<https://prismlauncher.org>).
- Go through [CMakeLists.txt](CMakeLists.txt) and change Prism Launcher's API keys to your own or set them to empty strings (`""`) to disable them (this way the program will still compile but the functionality requiring those keys will be disabled).

If you have any questions or want any clarification on the above conditions please make an issue and ask us.

If you are just building Prism Launcher for your distribution, please make sure to set the `Launcher_BUILD_PLATFORM` to a slug representing your distribution. Examples are `archlinux`, `fedora` and `nixpkgs`.

Note that if you build this software without removing the provided API keys in [CMakeLists.txt](CMakeLists.txt) you are accepting the following terms and conditions:

- [Microsoft Identity Platform Terms of Use](https://docs.microsoft.com/en-us/legal/microsoft-identity-platform/terms-of-use)
- [CurseForge 3rd Party API Terms and Conditions](https://support.curseforge.com/en/support/solutions/articles/9000207405-curse-forge-3rd-party-api-terms-and-conditions)

If you do not agree with these terms and conditions, then remove the associated API keys from the [CMakeLists.txt](CMakeLists.txt) file by setting them to an empty string (`""`).

## License [![https://github.com/Octol1ttle/ElyPrismLauncher/blob/develop/LICENSE](https://img.shields.io/github/license/Octol1ttle/ElyPrismLauncher?label=License&logo=gnu&color=C4282D)](LICENSE)

All launcher code is available under the GPL-3.0-only license.