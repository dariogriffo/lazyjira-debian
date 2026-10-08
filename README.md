![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/dariogriffo/lazyjira-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/dariogriffo/lazyjira-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/dariogriffo/lazyjira-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/dariogriffo/lazyjira-debian)

<h1>
   <p align="center">
     <a href="https://github.com/textfuel/lazyjira"><img src="https://github.com/dariogriffo/lazyjira-debian/blob/main/lazyjira.svg" alt="lazyjira Logo" width="128" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/dariogriffo/lazyjira-debian/blob/main/debian-logo.png" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>lazyjira for Debian
   </p>
</h1>
<p align="center">
 lazyjira is a fast, keyboard-driven terminal UI for Jira, in the style of lazygit.
</p>

# lazyjira for Debian

This repository contains build scripts to produce the _unofficial_ Debian packages
(.deb) for [lazyjira](https://github.com/textfuel/lazyjira/) hosted at [deb.griffo.io](https://deb.griffo.io)

Currently supported Debian distros are:
- Bookworm (v12)
- Trixie (v13)
- Forky (v14)
- Sid (testing)

Currently supported Ubuntu distros are:
- Jammy (22.04)
- Noble (24.04)
- Questing (25.10)
- Resolute (26.04)

Supported architectures:
- amd64 (x86_64) - All distributions
- arm64 (aarch64) - All distributions

Upstream publishes no i386, armel, armhf or riscv64 binaries, so those
architectures are not available.

The packages include the lazyjira binary, the upstream changelog and the
upstream documentation (`Config.md`, `Keybindings.md`, `Custom_Fields.md`)
under `/usr/share/doc/lazyjira/`. Upstream ships no man page and no shell
completions; press `?` inside the app for the keybindings.

> ℹ️ The package has **no dependencies**: it installs a statically linked
> binary, just like downloading the upstream release. `git` (branches from
> issues), `xclip` (copy to clipboard) and `xdg-utils` (open in browser) are
> only **suggested**; lazyjira runs without them and only that action is
> unavailable.

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the lazyjira source code, see
[lazyjira](https://github.com/textfuel/lazyjira/).

## Install/Update

📖 **Step-by-step install guide:** [Debian](https://deb.griffo.io/install-latest-lazyjira-in-debian.html) · [Ubuntu](https://deb.griffo.io/install-latest-lazyjira-in-ubuntu.html)

### The Debian way

> ⚠️ **apt access requires a yearly subscription**
> ([deb.griffo.io](https://deb.griffo.io)). To use this tool for free, download
> the .deb from the [Releases](https://github.com/dariogriffo/lazyjira-debian/releases) page
> and install it manually (see below).

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/deb.griffo.io.gpg
echo "deb [signed-by=/etc/apt/keyrings/deb.griffo.io.gpg] https://deb.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/deb.griffo.io.list
sudo apt update
sudo apt install -y lazyjira
```

### Manual Installation

1. Download the .deb package for your Debian version available on
   the [Releases](https://github.com/dariogriffo/lazyjira-debian/releases) page.
2. Install the downloaded .deb package.

```sh
sudo dpkg -i <filename>.deb
```
## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Building

### Build for single architecture
```sh
./build.sh <lazyjira_version> <build_version> <architecture>
# Example: ./build.sh 2.19.2 1 arm64
```

### Build for all architectures
```sh
./build.sh <lazyjira_version> <build_version> all
# Example: ./build.sh 2.19.2 1 all
```

## Roadmap

- [x] Produce a .deb package on GitHub Releases
- [x] Set up a debian mirror for easier updates
- [x] Multi-architecture support (amd64, arm64)

## Disclaimer

- This repo is not open for issues related to lazyjira. This repo is only for _unofficial_ Debian packaging.
