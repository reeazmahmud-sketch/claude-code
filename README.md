# Claude Code

![](https://img.shields.io/badge/Node.js-18%2B-brightgreen?style=flat-square) [![npm]](https://www.npmjs.com/package/@anthropic-ai/claude-code)

[npm]: https://img.shields.io/npm/v/@anthropic-ai/claude-code.svg?style=flat-square

Claude Code is an agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster by executing routine tasks, explaining complex code, and handling git workflows -- all through natural language commands. Use it in your terminal, IDE, or tag @claude on Github.

**Learn more in the [official documentation](https://docs.anthropic.com/en/docs/claude-code/overview)**.

<img src="./demo.gif" />

## Get started

1. Install Claude Code:

```sh
npm install -g @anthropic-ai/claude-code
```

2. Navigate to your project directory and run `claude`.

## SideAi - macOS Productivity App

This repository now includes **SideAi**, a modern macOS productivity application built with Swift and SwiftUI, inspired by Side.ai.

### Features
- 🎯 **Task Management**: Create, organize, and track tasks with priorities
- 📅 **Schedule & Events**: Visual calendar with event management
- 🔔 **Smart Reminders**: Customizable reminders with repeat options
- 🔐 **Secure Storage**: Encrypted data using macOS Keychain
- ⚙️ **Customizable Settings**: Themes, notifications, and preferences
- 🎨 **Elegant UI**: Native SwiftUI interface following Apple HIG

### Quick Start
```bash
cd SideAiMacApp
swift build
swift run
```

For detailed documentation, see:
- [SideAiMacApp/README.md](./SideAiMacApp/README.md) - Overview and features
- [SideAiMacApp/QUICKSTART.md](./SideAiMacApp/QUICKSTART.md) - Quick start guide
- [SideAiMacApp/DEVELOPMENT.md](./SideAiMacApp/DEVELOPMENT.md) - Development guide
- [SideAiMacApp/FEATURES.md](./SideAiMacApp/FEATURES.md) - Complete feature list

**Requirements**: macOS 13.0+, Swift 6.0+, Xcode 15.0+ (recommended)

---

## Plugins

This repository includes several Claude Code plugins that extend functionality with custom commands and agents. See the [plugins directory](./plugins/README.md) for detailed documentation on available plugins.

## Reporting Bugs

We welcome your feedback. Use the `/bug` command to report issues directly within Claude Code, or file a [GitHub issue](https://github.com/anthropics/claude-code/issues).

## Connect on Discord

Join the [Claude Developers Discord](https://anthropic.com/discord) to connect with other developers using Claude Code. Get help, share feedback, and discuss your projects with the community.

## Data collection, usage, and retention

When you use Claude Code, we collect feedback, which includes usage data (such as code acceptance or rejections), associated conversation data, and user feedback submitted via the `/bug` command.

### How we use your data

See our [data usage policies](https://docs.anthropic.com/en/docs/claude-code/data-usage).

### Privacy safeguards

We have implemented several safeguards to protect your data, including limited retention periods for sensitive information, restricted access to user session data, and clear policies against using feedback for model training.

For full details, please review our [Commercial Terms of Service](https://www.anthropic.com/legal/commercial-terms) and [Privacy Policy](https://www.anthropic.com/legal/privacy).
