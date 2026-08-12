local source = debug.getinfo(1, 'S').source
local resourceName = source:match("@@([^/]+)/") or 'Dank_Utils'

local loadedModules = {}

local function customRequire(modname)
    if loadedModules[modname] then return loadedModules[modname] end

    local p = modname:gsub('%.', '/') .. '.lua'
    local data = LoadResourceFile(resourceName, p)
    if data then
        local customEnv = setmetatable({ require = customRequire }, { __index = _ENV })
        local chunk, err = load(data, '@@' .. resourceName .. '/' .. p, 't', customEnv)
        if chunk then
            local result = chunk()
            loadedModules[modname] = result
            return result
        else
            print(('^1[Dank_Utils] Error compiling require %s: %s^0'):format(modname, tostring(err)))
        end
    end
    return require(modname)
end

Dank = setmetatable({}, {
    __index = function(self, key)
        if key == 'config' then
            local sharedConfig = customRequire('config.dankutils_shared')
            self.config = sharedConfig
            return sharedConfig
        end
        local filePath = 'modules/' .. key .. '.lua'
        local fileData = LoadResourceFile(resourceName, filePath)

        if fileData then
            -- Load the module chunk with the custom customRequire injected
            local customEnv = setmetatable({ require = customRequire }, { __index = _ENV })
            local chunk, err = load(fileData, '@@' .. resourceName .. '/' .. filePath, 't', customEnv)

            if chunk then
                local moduleTable = chunk()
                -- Cache it so we don't load it again
                self[key] = moduleTable
                return moduleTable
            else
                print(('^1[Dank_Utils] Error compiling module %s: %s^0'):format(key, tostring(err)))
            end
        else
            print(('^1[Dank_Utils] Error: Could not find module %s in %s^0'):format(key, filePath))
        end
        return nil
    end
})
