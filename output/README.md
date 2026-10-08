<div align="center">

# lazyjira

**Terminal UI for Jira. Like lazygit, but for Jira.**

![GitHub Release](https://img.shields.io/github/v/release/textfuel/lazyjira)
![GitHub License](https://img.shields.io/github/license/textfuel/lazyjira)

</div>

## About

Jira's web UI is slow: changing a ticket status takes several clicks and pages
take seconds to load. lazyjira gives you a fast, keyboard-driven terminal UI to
browse issues, update statuses, read descriptions and more with minimum
latency.

## Features

- **JQL search** with autocomplete, syntax highlighting and persistent history
- **4-panel layout** (issues, projects, detail, status) with vim-style navigation
- **Inline editing**: transitions, priority, assignee, labels, comments and
  description (in `$EDITOR`)
- **Configurable**: custom keybindings (including navigation keys), JQL tabs,
  issue columns and custom fields
- **Themes**: the default ANSI palette plus all four Catppuccin flavours
- **Adaptive**: side-by-side or stacked layout, mouse support
- **Git integration**: create branches from issues, open the issue for the
  current branch

## Setup

Run `lazyjira`. On first launch the setup wizard asks for your Jira type
(Cloud or Server/Data Center), host and credentials.

- **Jira Cloud**: your email and an API token, created at
  <https://id.atlassian.com/manage-profile/security/api-tokens>
- **Jira Server / Data Center**: a Personal Access Token (Profile > Personal
  Access Tokens > Create token). For client certificates (mTLS) see
  `docs/Config.md`.

Credentials are saved to `~/.config/lazyjira/auth.json` and the configuration
lives in `~/.config/lazyjira/config.yml`.

## Usage

```
lazyjira                 # start
lazyjira auth            # re-authenticate
lazyjira logout          # clear credentials
lazyjira --dry-run       # read-only mode (no writes to Jira)
lazyjira --log app.log   # log API requests to file
lazyjira --version       # show version
```

Press `?` inside the app for all keybindings.

## Optional helpers

The package has no dependencies. These tools are suggested, and lazyjira
works without them; only the related action is unavailable:

- `git`: create and check out branches named after issues
- `xclip`: copy issue keys and URLs to the clipboard
- `xdg-utils` (`xdg-open`): open issues in the web browser

## Documentation

Installed in `/usr/share/doc/lazyjira/`:

- `docs/Config.md`: config file, keybindings, issue tabs, custom fields, git
  integration, themes, TLS
- `docs/Keybindings.md`: full list of default keys
- `docs/Custom_Fields.md`: displaying Jira custom fields
- `changelog.gz`: the upstream changelog

Upstream repository: <https://github.com/textfuel/lazyjira>
