# Draft PR: Add OmniLadle.spoon – Omnispindle MCP Client Spoon

## Summary

This PR adds **OmniLadle.spoon**, a mystical Hammerspoon Spoon for connecting to an Omnispindle MCP (Model Context Protocol) server, providing real-time and HTTP-based project management integration for Hammerspoon users.

## Features

- Real-time project updates via SSE (Server-Sent Events)
- Fallback HTTP mode for legacy/compatibility
- Automatic connection management and error recovery
- Rich, themed logging (with override support)
- Secrets/configuration via `hs.settings` or `.secrets` file
- Project list API compatible with FileManager

## Installation & Configuration

```bash
cd ~/.hammerspoon/Spoons
git clone https://github.com/madness-interactive/OmniLadle.spoon.git
cp ~/.hammerspoon/Spoons/OmniLadle.spoon/.secrets.example ~/.hammerspoon/.secrets
# Edit ~/.hammerspoon/.secrets as needed
```

## Usage Example

```lua
hs.loadSpoon("OmniLadle")
spoon.OmniLadle:start()
local projects = spoon.OmniLadle:getProjectsList()
```

## Highlights

- No external dependencies (uses only Hammerspoon APIs)
- MIT License included
- Example config and improved README for onboarding
- Logger override pattern for advanced users
- Thorough error handling and fallback logic

## Checklist for Hammerspoon/Spoons Submission

- [x] MIT LICENSE file present
- [x] README with install, config, and usage
- [x] Example configuration file (`.secrets.example`)
- [x] No external Lua dependencies
- [x] Uses only Hammerspoon APIs (`hs.logger`, `hs.settings`, etc.)
- [x] All config can be set via `hs.settings` or `.secrets`
- [x] Logging can be overridden for advanced use
- [x] Thorough error handling and user feedback
- [x] API documented in `docs.json`

## Maintainer Notes

- This Spoon is designed to be robust for both new and advanced users.
- All legacy dependencies have been removed.
- Please advise if further changes are needed for upstream acceptance.

---

*Embrace the Madness! 🥄✨*
