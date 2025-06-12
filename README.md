# OmniLadle.spoon

> *The mystical ladle that serves up fresh data from the Omnispindle's depths*

A Hammerspoon Spoon for connecting to the Omnispindle MCP (Model Context Protocol) server, providing seamless integration with centralized project management. 🥄✨

## Features

- **Real-time Updates**: SSE (Server-Sent Events) support for live project updates
- **Fallback HTTP Mode**: Traditional HTTP requests when SSE isn't available
- **Automatic Connection Management**: Handles reconnection and error recovery
- **Rich Logging**: Mystical-themed logs with technical precision
- **Secrets Integration**: Uses Hammerspoon's secrets system for configuration
- **Project Management**: Serves up fresh project lists from the Omnispindle

## Installation

### Method 1: Git Clone

```bash
cd ~/.hammerspoon/Spoons
git clone https://github.com/madness-interactive/OmniLadle.spoon.git
```

### Method 2: Manual Download

1. Download the spoon files
2. Place in `~/.hammerspoon/Spoons/OmniLadle.spoon/`

### Configuration

1. Copy the example secrets file:

   ```bash
   cp ~/.hammerspoon/Spoons/OmniLadle.spoon/.secrets.example ~/.hammerspoon/.secrets
   ```

2. Edit `~/.hammerspoon/.secrets` to match your Omnispindle server settings.

```bash
# Omnispindle MCP Server Configuration
MCP_SERVER_URL=http://your-omnispindle-server:8000
MCP_CLIENT_MODE=sse  # or "http" for legacy mode
MCP_TIMEOUT=30       # Connection timeout in seconds
```

## Usage

### Basic Setup

```lua
-- Load and start the OmniLadle spoon
hs.loadSpoon("OmniLadle")
spoon.OmniLadle:start()
```

### Getting Projects

```lua
-- Get fresh projects from the Omnispindle
local projects = spoon.OmniLadle:getProjectsList()
if projects then
    for _, project in ipairs(projects) do
        print("Project:", project.name, "Path:", project.path)
    end
end

-- Force refresh from server
local freshProjects = spoon.OmniLadle:getProjectsList(true)
```

### Connection Management

```lua
-- Test connection to Omnispindle
local connected = spoon.OmniLadle:testConnection()
if connected then
    print("Ladle is STIRRING NICELY")
else
    print("Ladle is DRY")
end

-- Get detailed connection status
local status = spoon.OmniLadle:getConnectionStatus()
print("Connection:", status.connected)
print("Client Type:", status.clientType)
print("Ladle Status:", status.ladleStatus)
```

### Advanced Configuration

```lua
-- Custom configuration before starting
spoon.OmniLadle.config.serverUrl = "http://custom-server:8000"
spoon.OmniLadle.config.clientMode = "http"
spoon.OmniLadle.config.timeout = 60

spoon.OmniLadle:start()
```

## API Reference

### Methods

#### `OmniLadle:init()`

Initializes the OmniLadle spoon and loads configuration from secrets.

#### `OmniLadle:start()`

Starts the spoon and initializes the MCP client connection.

- Returns: `true` if successful, `false` otherwise

#### `OmniLadle:stop()`

Stops the spoon and cleans up resources.

#### `OmniLadle:getProjectsList([forceRefresh])`

Ladles up projects from the Omnispindle.

- Parameters:
  - `forceRefresh` (optional): Boolean to force server refresh
- Returns: Array of project objects or `nil` if failed

#### `OmniLadle:testConnection()`

Tests connection to the Omnispindle server.

- Returns: `true` if connected, `false` otherwise

#### `OmniLadle:getConnectionStatus()`

Gets detailed connection status information.

- Returns: Table with status details

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `serverUrl` | `http://localhost:8000` | Omnispindle server URL |
| `timeout` | `30` | Connection timeout in seconds |
| `clientMode` | `sse` | Client mode: "sse" or "http" |
| `enableLogging` | `true` | Enable mystical logging |

## Logging

OmniLadle provides rich, themed logging:

- **STIRRING**: SSE connection active
- **RESTING**: SSE connection idle
- **SERVING**: HTTP mode active  
- **LADLE DRY**: Connection failed
- **STIRRING NICELY**: Connection successful

## Troubleshooting

### Connection Issues

1. Verify your `.secrets` file configuration
2. Check if Omnispindle server is running
3. Test network connectivity to the server
4. Check Hammerspoon console for error messages

### SSE Mode Issues

- Fallback to HTTP mode: Set `MCP_CLIENT_MODE=http` in `.secrets`
- Check server SSE endpoint availability
- Verify timeout settings aren't too aggressive

### Project Loading Issues

- Ensure Omnispindle server has proper project data
- Check server logs for API errors
- Try force refresh: `getProjectsList(true)`

## Integration with FileManager

OmniLadle is designed to work seamlessly with Hammerspoon's FileManager:

```lua
-- FileManager will automatically use OmniLadle when available
local FileManager = require('FileManager')
local projects = FileManager.getProjectsList() -- Uses OmniLadle internally
```

## Contributing

The mystical ladle welcomes contributions! Please see the main repository for contribution guidelines.

## License

MIT License - See LICENSE file for details.

---

*"In the depths of the Omnispindle's wisdom, the OmniLadle stirs, serving up knowledge to those who dare to tinker with madness."* 🧙‍♂️⚡️
