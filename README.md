# FastGit

**GitHub review requests, always visible in your menu bar.**

FastGit is a lightweight macOS menu bar app that shows pull requests waiting for your review. No more missing review requests buried in GitHub's notification noise.

---

## Why

GitHub's notification system mixes review requests with hundreds of other events. Important PRs waiting for your review get lost. FastGit fixes this by putting them right where you can always see them -- your menu bar.

## Features

- **Menu bar native** -- lives in your menu bar, no Dock icon, no windows
- **Review count badge** -- see pending review count at a glance
- **macOS notifications** -- get notified when new review requests arrive
- **One-click open** -- click any PR to open it directly in your browser
- **Auto-refresh** -- polls GitHub every 60 seconds
- **Auto-cleanup** -- reviewed PRs disappear automatically

## Install

### Download

Download the latest `.dmg` from [GitHub Releases](https://github.com/Eronred/FastGit-Menu/releases/latest), open it, and drag **FastGit Menu** to your Applications folder. The app is signed and notarized -- it will open without any warnings.

### Build from source

Requires Xcode 16+ and macOS 14+.

```bash
git clone https://github.com/Eronred/FastGit-Menu.git
cd FastGit-Menu
make build
```

The built app will be at `build/FastGit Menu.app`. To create a DMG:

```bash
make dmg
```

## Setup

1. Launch **FastGit Menu** -- a pull request icon appears in your menu bar
2. Click the icon and enter your GitHub Personal Access Token
3. That's it -- your pending reviews will appear

### Creating a GitHub token

1. Go to [GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)](https://github.com/settings/tokens)
2. Click **Generate new token (classic)**
3. Select the **`repo`** scope
4. Generate and copy the token
5. Paste it into FastGit

## How it works

FastGit uses the GitHub Search API to find open pull requests where you're requested as a reviewer:

```
GET /search/issues?q=type:pr+state:open+review-requested:{username}
```

Once you submit a review, GitHub removes you from the `review-requested` list and the PR automatically disappears from FastGit.

## Tech stack

- Swift + SwiftUI
- `MenuBarExtra` (macOS 13+)
- GitHub REST API v3
- `UserNotifications` for native macOS alerts
- No external dependencies

## Contributing

Contributions are welcome! Feel free to open issues and pull requests.

## License

[MIT](LICENSE)
