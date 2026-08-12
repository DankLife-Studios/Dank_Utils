local TriggerEvent = TriggerEvent
local exports = exports
local print = print
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local type = type
local table = table

local sharedConfig = require 'config.dankutils_shared'
local menu = {}
local registeredMenus = {}

if not IsDuplicityVersion() then
    -- CLIENT

    -- Register a menu definition
    -- menuData expects: { id = string, title = string, options = table }
    menu.register = function(menuData)
        if type(menuData) ~= 'table' or not menuData.id then
            print('^3[Dank_Utils] Menu: Invalid menuData passed to register.^0')
            return
        end
        registeredMenus[menuData.id] = menuData

        local menuType = sharedConfig.Menu
        if menuType == 'ox_lib' then
            if not lib then return end
            local formattedOptions = {}
            for _, opt in ipairs(menuData.options or {}) do
                table.insert(formattedOptions, {
                    title = opt.title or opt.header,
                    description = opt.description or opt.txt,
                    icon = opt.icon,
                    image = opt.image,
                    menu = opt.menu,
                    onSelect = opt.onSelect,
                    event = opt.event or (opt.params and opt.params.event),
                    args = opt.args or (opt.params and opt.params.args)
                })
            end
            lib.registerContext({
                id = menuData.id,
                title = menuData.title or menuData.header,
                options = formattedOptions
            })
        end
    end

    -- Show a registered menu by ID
    menu.show = function(id)
        local menuType = sharedConfig.Menu
        local registered = registeredMenus[id]

        if menuType == 'ox_lib' then
            if not lib then print('^3[Dank_Utils] Menu: ox_lib not found.^0') return end
            lib.showContext(id)
        elseif menuType == 'qb-menu' then
            if not registered then
                print('^3[Dank_Utils] Menu: No registered menu found with id "' .. tostring(id) .. '".^0')
                return
            end
            local qbMenuData = {
                {
                    header = registered.title or registered.header or id,
                    isMenuHeader = true,
                }
            }
            for _, opt in ipairs(registered.options or {}) do
                local headerText = opt.title or opt.header or ''
                if opt.image then
                    headerText = headerText .. ' <img src="' .. opt.image .. '" alt="' .. headerText .. '">'
                end
                table.insert(qbMenuData, {
                    header = headerText,
                    txt = opt.description or opt.txt,
                    icon = opt.icon,
                    params = {
                        event = opt.event or (opt.params and opt.params.event),
                        args = opt.args or (opt.params and opt.params.args)
                    }
                })
            end
            exports['qb-menu']:openMenu(qbMenuData)
        elseif menuType == 'nh-context' or menuType == 'zf_context' then
            if not registered then return end
            local contextData = {
                {
                    header = registered.title or registered.header or id,
                    isMenuHeader = true
                }
            }
            for _, opt in ipairs(registered.options or {}) do
                table.insert(contextData, {
                    header = opt.title or opt.header,
                    context = opt.description or opt.txt,
                    event = opt.event or (opt.params and opt.params.event),
                    args = { opt.args or (opt.params and opt.params.args) }
                })
            end
            if menuType == 'nh-context' then
                TriggerEvent('nh-context:sendMenu', contextData)
            else
                exports['zf_context']:openMenu(contextData)
            end
        else
            print('^3[Dank_Utils] Menu: Unsupported or undetected menu system (' .. tostring(menuType) .. ') for show.^0')
        end
    end

    -- Close any open menu
    menu.close = function()
        local menuType = sharedConfig.Menu
        if menuType == 'ox_lib' then
            if lib then lib.hideContext() end
        elseif menuType == 'qb-menu' then
            exports['qb-menu']:closeMenu()
        end
    end

    -- Open a menu directly on the fly
    menu.open = function(id, title, elements)
        menu.register({
            id = id,
            title = title,
            options = elements
        })
        menu.show(id)
    end
end

return menu
