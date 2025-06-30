-- MCPClient.lua - HTTP client for communicating with MCP servers
-- Provides centralized project management by calling Omnispindle MCP server

local log = nil

-- Check if module is already initialized
if _G.MCPClient then
    log:d('Returning existing MCPClient module')
    return _G.MCPClient
end

log:i('Initializing MCP client for centralized project management')

local MCPClient = {
    -- Configuration
    mcpServerUrl = "http://localhost:8080", -- Default MCP server URL
    timeout = 10,                           -- Request timeout in seconds

    -- Cache for project list
    projectsCache = nil,
    cacheTimestamp = 0,
    cacheTimeout = 300 -- 5 minutes cache
}

function MCPClient.setLogger(customLogger)
    log = customLogger or hs.logger.new('MCPClient')
end

-- Initialize MCP client with configuration
function MCPClient.init(config)
    if not log then log = hs.logger.new('MCPClient') end
    log:d('Initializing MCP client with config')
    config = config or {}

    if config.serverUrl then
        MCPClient.mcpServerUrl = config.serverUrl
    end

    if config.timeout then
        MCPClient.timeout = config.timeout
    end

    log:i('MCP client initialized with server: ' .. MCPClient.mcpServerUrl)
    return true
end

-- Make HTTP request to MCP server
function MCPClient.makeRequest(method, endpoint, params)
    log:d('Making MCP request: ' .. method .. ' ' .. endpoint)

    local url = MCPClient.mcpServerUrl .. endpoint
    local success, result = pcall(function()
        -- Using hs.http for HTTP requests
        local headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        }

        local body = nil
        if params and (method == "POST" or method == "PUT" or method == "PATCH") then
            body = hs.json.encode(params)
        elseif params and method == "GET" then
            -- Convert params to query string for GET requests
            local queryParams = {}
            for k, v in pairs(params) do
                table.insert(queryParams, k .. "=" .. tostring(v))
            end
            if #queryParams > 0 then
                url = url .. "?" .. table.concat(queryParams, "&")
            end
        end

        local status, response = hs.http.doRequest(url, method, body, headers, MCPClient.timeout)

        if status == 200 then
            local data = hs.json.decode(response)
            return { success = true, data = data }
        else
            log:w('MCP request failed with status: ' .. status)
            return { success = false, error = "HTTP " .. status, response = response }
        end
    end)

    if success then
        log:d('MCP request completed successfully')
        return result
    else
        log:e('MCP request error: ' .. (result or "unknown error"))
        return { success = false, error = result }
    end
end

-- ============================================================================
-- TODO MANAGEMENT FUNCTIONS
-- ============================================================================

-- Add a new todo
function MCPClient.addTodo(description, project, metadata, priority, targetAgent)
    log:d('Adding todo: ' .. description)

    local params = {
        description = description,
        project = project
    }

    if metadata then params.metadata = metadata end
    if priority then params.priority = priority end
    if targetAgent then params.target_agent = targetAgent end

    return MCPClient.makeRequest("POST", "/api/todos", params)
end

-- Query todos with filtering
function MCPClient.queryTodos(ctx, filter, limit, projection)
    log:d('Querying todos')

    local params = {}
    if ctx then params.ctx = ctx end
    if filter then params.filter = filter end
    if limit then params.limit = limit end
    if projection then params.projection = projection end

    return MCPClient.makeRequest("GET", "/api/todos/query", params)
end

-- Update a todo
function MCPClient.updateTodo(todoId, updates)
    log:d('Updating todo: ' .. todoId)

    local params = {
        todo_id = todoId,
        updates = updates
    }

    return MCPClient.makeRequest("PUT", "/api/todos/" .. todoId, params)
end

-- Delete a todo
function MCPClient.deleteTodo(todoId)
    log:d('Deleting todo: ' .. todoId)

    return MCPClient.makeRequest("DELETE", "/api/todos/" .. todoId)
end

-- Get a specific todo
function MCPClient.getTodo(todoId)
    log:d('Getting todo: ' .. todoId)

    return MCPClient.makeRequest("GET", "/api/todos/" .. todoId)
end

-- Mark todo as complete
function MCPClient.markTodoComplete(todoId, comment)
    log:d('Marking todo complete: ' .. todoId)

    local params = {
        todo_id = todoId
    }
    if comment then params.comment = comment end

    return MCPClient.makeRequest("POST", "/api/todos/" .. todoId .. "/complete", params)
end

-- List todos by status
function MCPClient.listTodosByStatus(status, limit)
    log:d('Listing todos by status: ' .. status)

    local params = {
        status = status
    }
    if limit then params.limit = limit end

    return MCPClient.makeRequest("GET", "/api/todos/status/" .. status, params)
end

-- Search todos
function MCPClient.searchTodos(query, ctx, fields, limit)
    log:d('Searching todos with query: ' .. query)

    local params = {
        query = query
    }
    if ctx then params.ctx = ctx end
    if fields then params.fields = fields end
    if limit then params.limit = limit end

    return MCPClient.makeRequest("GET", "/api/todos/search", params)
end

-- List project todos
function MCPClient.listProjectTodos(project, limit)
    log:d('Listing todos for project: ' .. project)

    local params = {
        project = project
    }
    if limit then params.limit = limit end

    return MCPClient.makeRequest("GET", "/api/projects/" .. project .. "/todos", params)
end

-- Query todo logs
function MCPClient.queryTodoLogs(filterType, page, pageSize, project)
    log:d('Querying todo logs')

    local params = {}
    if filterType then params.filter_type = filterType end
    if page then params.page = page end
    if pageSize then params.page_size = pageSize end
    if project then params.project = project end

    return MCPClient.makeRequest("GET", "/api/todos/logs", params)
end

-- ============================================================================
-- LESSON MANAGEMENT FUNCTIONS
-- ============================================================================

-- Add a new lesson
function MCPClient.addLesson(language, lessonLearned, topic, tags)
    log:d('Adding lesson: ' .. topic)

    local params = {
        language = language,
        lesson_learned = lessonLearned,
        topic = topic
    }
    if tags then params.tags = tags end

    return MCPClient.makeRequest("POST", "/api/lessons", params)
end

-- Get a specific lesson
function MCPClient.getLesson(lessonId)
    log:d('Getting lesson: ' .. lessonId)

    return MCPClient.makeRequest("GET", "/api/lessons/" .. lessonId)
end

-- Update a lesson
function MCPClient.updateLesson(lessonId, updates)
    log:d('Updating lesson: ' .. lessonId)

    local params = {
        lesson_id = lessonId,
        updates = updates
    }

    return MCPClient.makeRequest("PUT", "/api/lessons/" .. lessonId, params)
end

-- Delete a lesson
function MCPClient.deleteLesson(lessonId)
    log:d('Deleting lesson: ' .. lessonId)

    return MCPClient.makeRequest("DELETE", "/api/lessons/" .. lessonId)
end

-- Search lessons with grep-style pattern matching
function MCPClient.grepLessons(pattern, limit)
    log:d('Grep searching lessons with pattern: ' .. pattern)

    local params = {
        pattern = pattern
    }
    if limit then params.limit = limit end

    return MCPClient.makeRequest("GET", "/api/lessons/grep", params)
end

-- List all lessons
function MCPClient.listLessons(limit)
    log:d('Listing all lessons')

    local params = {}
    if limit then params.limit = limit end

    return MCPClient.makeRequest("GET", "/api/lessons", params)
end

-- Search lessons with text search
function MCPClient.searchLessons(query, fields, limit)
    log:d('Searching lessons with query: ' .. query)

    local params = {
        query = query
    }
    if fields then params.fields = fields end
    if limit then params.limit = limit end

    return MCPClient.makeRequest("GET", "/api/lessons/search", params)
end

-- ============================================================================
-- PROJECT MANAGEMENT FUNCTIONS (Enhanced)
-- ============================================================================

-- Get projects list from MCP server (Enhanced)
function MCPClient.getProjectsList(forceRefresh)
    log:d('Getting projects list from MCP server')

    -- Check cache first
    local currentTime = os.time()
    if not forceRefresh and MCPClient.projectsCache and
        (currentTime - MCPClient.cacheTimestamp) < MCPClient.cacheTimeout then
        log:d('Returning cached projects list')
        return { success = true, data = MCPClient.projectsCache }
    end

    -- Make request to MCP server
    local result = MCPClient.makeRequest("GET", "/api/projects", nil)

    if result.success then
        -- Update cache
        MCPClient.projectsCache = result.data.projects or result.data
        MCPClient.cacheTimestamp = currentTime
        log:i('Retrieved ' .. #MCPClient.projectsCache .. ' projects from MCP server')
        return result
    else
        log:w('Failed to get projects from MCP server: ' .. (result.error or "unknown error"))

        -- Return cached data if available as fallback
        if MCPClient.projectsCache then
            log:w('Returning cached projects as fallback')
            return { success = true, data = MCPClient.projectsCache, cached = true }
        end

        return result
    end
end

-- List projects with detailed information
function MCPClient.listProjects(includeDetails, madnessRoot)
    log:d('Listing projects from MCP server')

    local params = {}
    if includeDetails ~= nil then params.include_details = includeDetails end
    if madnessRoot then params.madness_root = madnessRoot end

    return MCPClient.makeRequest("GET", "/api/projects/list", params)
end

-- Explain a project or concept
function MCPClient.explain(topic)
    log:d('Getting explanation for topic: ' .. topic)

    local params = {
        topic = topic
    }

    return MCPClient.makeRequest("GET", "/api/explain", params)
end

-- Add a new explanation
function MCPClient.addExplanation(content, topic, author, kind)
    log:d('Adding explanation for topic: ' .. topic)

    local params = {
        content = content,
        topic = topic
    }
    if author then params.author = author end
    if kind then params.kind = kind end

    return MCPClient.makeRequest("POST", "/api/explanations", params)
end

-- ============================================================================
-- LEGACY COMPATIBILITY FUNCTIONS
-- ============================================================================
-- Convert MCP project list to FileManager format for compatibility
function MCPClient.convertToFileManagerFormat(mcpProjects)
    log:d('Converting MCP projects to FileManager format')

    local converted = {}
    for _, project in ipairs(mcpProjects) do
        table.insert(converted, {
            name = project,
            path = "~/lab/madness_interactive/projects/" .. project:lower(), -- Default path pattern
            description = "Project from centralized MCP server"
        })
    end

    log:d('Converted ' .. #converted .. ' projects to FileManager format')
    return converted
end

-- Get projects list in FileManager compatible format
function MCPClient.getProjectsListForFileManager(forceRefresh)
    log:d('Getting projects list for FileManager compatibility')

    local result = MCPClient.getProjectsList(forceRefresh)

    if result.success then
        local converted = MCPClient.convertToFileManagerFormat(result.data)
        return { success = true, data = converted, cached = result.cached }
    else
        return result
    end
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
-- Test MCP server connectivity
function MCPClient.testConnection()
    log:d('Testing MCP server connection')

    local result = MCPClient.makeRequest("GET", "/api/health", nil)

    if result.success then
        log:i('MCP server connection test successful')
        return true
    else
        log:w('MCP server connection test failed: ' .. (result.error or "unknown error"))
        return false
    end
end

-- Clear projects cache
function MCPClient.clearCache()
    log:d('Clearing MCP projects cache')
    MCPClient.projectsCache = nil
    MCPClient.cacheTimestamp = 0
end

-- Initialize the module
log:i('MCP client module loaded successfully with full MCP toolset support')

-- Make module globally accessible
_G.MCPClient = MCPClient

return MCPClient
