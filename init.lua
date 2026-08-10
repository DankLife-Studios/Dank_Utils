local source = debug.getinfo(1, 'S').source
local resourceName = source:match("@@([^/]+)/") or 'Dank_Utils'

Dank = setmetatable({}, {
    __index = function(self, key)
        local filePath = 'modules/' .. key .. '.lua'
        local fileData = LoadResourceFile(resourceName, filePath)

        if fileData then
            -- Load the module chunk with the current _ENV so it inherits natives and globals
            local chunk, err = load(fileData, '@@' .. resourceName .. '/' .. filePath, 't', _ENV)

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
