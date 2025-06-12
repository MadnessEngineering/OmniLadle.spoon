-- OmniLadle.spoon
-- MCP client spoon for connecting to Omnispindle server
-- The mystical ladle that serves up fresh data from the Omnispindle's depths

local obj = {}
obj.__index = obj

-- Metadata (required for Spoons)
obj.name = "OmniLadle"
obj.version = "1.0.0"
obj.author = "Mad Tinker <d.edens@madness.interactive>"
obj.homepage = "https://github.com/madness-interactive/OmniLadle.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new('OmniLadle')

-- Configuration
obj.config = {
    serverUrl = nil,
    timeout = 30,
    clientMode = "sse", -- "sse" or "http"
    enableLogging = true
}

-- State
obj.isInitialized = false
obj.mcpClient = nil
obj.clientType = nil

--- OmniLadle:init()
--- Method
--- Initializes the OmniLadle spoon
---
--- Parameters:
---  * None
---
--- Returns:
---  * The OmniLadle object
function obj:init()
    self.logger.i("Initializing OmniLadle spoon - The mystical ladle awakens...")

    -- Load configuration from secrets or defaults
    local secrets = require("load_secrets")
    if secrets then
        self.config.serverUrl = secrets.get("MCP_SERVER_URL", "http://localhost:8000")
        self.config.timeout = tonumber(secrets.get("MCP_TIMEOUT", "30"))
        self.config.clientMode = secrets.get("MCP_CLIENT_MODE", "sse")

        self.logger.i("OmniLadle configured with server: " ..
            self.config.serverUrl .. " (mode: " .. self.config.clientMode .. ")")
    else
        self.logger.w("Could not load secrets, using default configuration")
        self.config.serverUrl = "http://localhost:8000"
    end

    self.isInitialized = true
    return self
end

--- OmniLadle:start()
--- Method
--- Starts the OmniLadle spoon and initializes MCP client
---
--- Parameters:
---  * None
---
--- Returns:
---  * True if started successfully, false otherwise
function obj:start()
    if not self.isInitialized then
        self.logger.e("OmniLadle not initialized, call init() first")
        return false
    end

    self.logger.i("Starting OmniLadle - Preparing the mystical ladle...")

    -- Initialize appropriate MCP client based on configuration
    local success = self:_initializeMCPClient()
    if success then
        self.logger.i("OmniLadle started successfully - The ladle is ready to serve!")
        return true
    else
        self.logger.e("Failed to start OmniLadle - The ladle remains dormant")
        return false
    end
end

--- OmniLadle:stop()
--- Method
--- Stops the OmniLadle spoon and cleans up resources
---
--- Parameters:
---  * None
---
--- Returns:
---  * The OmniLadle object
function obj:stop()
    self.logger.i("Stopping OmniLadle - The mystical ladle rests...")

    if self.mcpClient and self.mcpClient.stopSSEConnection then
        self.mcpClient.stopSSEConnection()
    end

    self.mcpClient = nil
    self.clientType = nil

    return self
end

--- OmniLadle:getProjectsList()
--- Method
--- Ladles up a fresh serving of projects from the Omnispindle
---
--- Parameters:
---  * forceRefresh - Optional boolean to force refresh from server
---
--- Returns:
---  * Table of projects, or nil if failed
function obj:getProjectsList(forceRefresh)
    if not self.mcpClient then
        self.logger.w("OmniLadle not ready - cannot serve projects")
        return nil
    end

    self.logger.d("Ladling up projects from Omnispindle" .. (forceRefresh and " (fresh serving)" or ""))

    local result = self.mcpClient.getProjectsListForFileManager(forceRefresh)
    if result and result.success and result.data then
        self.logger.i("OmniLadle served " .. #result.data .. " projects" ..
            (result.cached and " (cached)" or " (fresh)"))
        return result.data
    else
        self.logger.w("OmniLadle failed to serve projects: " .. (result and result.error or "unknown error"))
        return nil
    end
end

--- OmniLadle:testConnection()
--- Method
--- Tests the connection to the Omnispindle server
---
--- Parameters:
---  * None
---
--- Returns:
---  * True if connected, false otherwise
function obj:testConnection()
    if not self.mcpClient then
        self.logger.w("OmniLadle not ready - cannot test connection")
        return false
    end

    self.logger.d("Testing Omnispindle connection")
    local connected = self.mcpClient.testConnection()

    if connected then
        self.logger.i("OmniLadle connection to Omnispindle: STIRRING NICELY")
    else
        self.logger.w("OmniLadle connection to Omnispindle: LADLE DRY")
    end

    return connected
end

--- OmniLadle:getConnectionStatus()
--- Method
--- Gets detailed connection status information
---
--- Parameters:
---  * None
---
--- Returns:
---  * Table with connection status details
function obj:getConnectionStatus()
    if not self.mcpClient then
        return {
            connected = false,
            clientType = "none",
            message = "OmniLadle not initialized"
        }
    end

    if self.clientType == "sse" and self.mcpClient.getConnectionStatus then
        local status = self.mcpClient.getConnectionStatus()
        status.clientType = "sse"
        status.ladleStatus = status.connected and "STIRRING" or "RESTING"
        return status
    else
        return {
            connected = true, -- Assume HTTP is connected if client exists
            clientType = "http",
            ladleStatus = "SERVING",
            message = "HTTP ladle ready"
        }
    end
end

-- Private methods
function obj:_initializeMCPClient()
    self.logger.d("Initializing MCP client for OmniLadle (mode: " .. self.config.clientMode .. ")")

    if self.config.clientMode == "sse" then
        return self:_initializeSSEClient()
    else
        return self:_initializeHTTPClient()
    end
end

function obj:_initializeSSEClient()
    self.logger.d("Loading SSE client for real-time ladling")

    local spoonPath = hs.spoons.resourcePath("OmniLadle")
    local success, MCPClientSSE = pcall(function()
        return dofile(spoonPath .. "/MCPClientSSE.lua")
    end)

    if not success then
        self.logger.e("Failed to load MCP SSE client: " .. (MCPClientSSE or "unknown error"))
        return false
    end

    local initSuccess = MCPClientSSE.init({
        serverUrl = self.config.serverUrl,
        timeout = self.config.timeout,
        onConnectionStatus = function(connected, message)
            self.logger.i("OmniLadle SSE status: " .. (connected and "STIRRING" or "RESTING") .. " - " .. message)
        end
    })

    if initSuccess then
        self.mcpClient = MCPClientSSE
        self.clientType = "sse"

        -- Start SSE connection for real-time updates
        MCPClientSSE.startSSEConnection()

        self.logger.i("OmniLadle SSE client initialized - Real-time ladling enabled")
        return true
    else
        self.logger.e("Failed to initialize OmniLadle SSE client")
        return false
    end
end

function obj:_initializeHTTPClient()
    self.logger.d("Loading HTTP client for traditional ladling")

    local spoonPath = hs.spoons.resourcePath("OmniLadle")
    local success, MCPClient = pcall(function()
        return dofile(spoonPath .. "/MCPClient.lua")
    end)

    if not success then
        self.logger.e("Failed to load MCP HTTP client: " .. (MCPClient or "unknown error"))
        return false
    end

    local initSuccess = MCPClient.init({
        serverUrl = self.config.serverUrl,
        timeout = self.config.timeout
    })

    if initSuccess then
        self.mcpClient = MCPClient
        self.clientType = "http"

        self.logger.i("OmniLadle HTTP client initialized - Traditional ladling ready")
        return true
    else
        self.logger.e("Failed to initialize OmniLadle HTTP client")
        return false
    end
end

return obj
