local source = debug.getinfo(1, 'S').source
local resourceName = source:match("@@([^/]+)/") or 'Dank_Utils'

---@type table<string, any>
local loadedModules = {}

---Dank Utils debug logger. The real implementation is injected into each
---module's environment by the loader below; this declaration gives the
---language server a global signature to resolve in modules.
---@type fun(message: string)
LogDebug = LogDebug or function() end

---Loads a resource file as a module, sharing the cache with native require.
---@param modname string
---@return any
local function customRequire(modname)
    if loadedModules[modname] then return loadedModules[modname] end

    -- Share the native require cache so the same file is never loaded twice
    local cached = package and package.loaded and package.loaded[modname]
    if cached ~= nil then
        loadedModules[modname] = cached
        return cached
    end

    local p = modname:gsub('%.', '/') .. '.lua'
    local data = LoadResourceFile(resourceName, p)
    if data then
        local customEnv = setmetatable({ require = customRequire }, { __index = _ENV })
        local chunk, err = load(data, '@@' .. resourceName .. '/' .. p, 't', customEnv)
        if chunk then
            local result = chunk()
            loadedModules[modname] = result
            if package and package.loaded then
                package.loaded[modname] = result
            end
             return result
        else
            print(('^1[Dank_Utils] Error compiling require %s: %s^0'):format(modname, tostring(err)))
        end
    end
    return require(modname)
end

---Global utility API surface, lazily loaded per module.
---@class Dank
---@field config DankUtilsConfig
---@field banking DankBanking
---@field core DankCore
---@field debug DankDebug
---@field fuel DankFuel
---@field garage DankGarage
---@field inventory DankInventory
---@field keys DankKeys
---@field menu DankMenu
---@field permissions DankPermissions
---@field phone DankPhone
---@field player DankPlayer
---@field target DankTarget
---@field tcg DankTcg
---@field ui DankUi
---@field vehicle DankVehicle
---@field onPlayerLoaded fun(cb: function)
Dank = setmetatable({
    onPlayerLoaded = function(cb)
        Dank.core.onPlayerLoaded(cb)
    end
}, {
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
            -- Expose the real LogDebug so modules capture it instead of nil
            local sharedConfig = customRequire('config.dankutils_shared')
            customEnv.LogDebug = sharedConfig and sharedConfig.LogDebug or function() end
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
