local TriggerEvent = TriggerEvent
local exports = exports
local print = print
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local type = type
local table = table

local sharedConfig = require 'config.dankutils_shared'
local LogDebug = LogDebug

---@class DankMenu
local menu = {}
---@type table<string, table>
local registeredMenus = {}

if not IsDuplicityVersion() then
    -- CLIENT

    -- Register a menu definition
    -- menuData expects: { id = string, title = string, options = table }
    ---@param menuData table
    menu.register = function(menuData)
        if type(menuData) ~= 'table' or not menuData.id then
            LogDebug('[menu] register: invalid menuData')
            print('^3[Dank_Utils] Menu: Invalid menuData passed to register.^0')
            return
        end
        LogDebug(('[menu] register(id=%s, title=%s) system=%s'):format(tostring(menuData.id), tostring(menuData.title), tostring(sharedConfig.Menu)))
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
                    metadata = opt.metadata,
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
    ---@param id string
    menu.show = function(id)
        local menuType = sharedConfig.Menu
        local registered = registeredMenus[id]
        LogDebug(('[menu] show(id=%s) system=%s'):format(tostring(id), tostring(menuType)))

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
        elseif menuType == 'esx_menu_default' then
            if not registered then return end
            local ESX = exports['es_extended']:getSharedObject()
            if not ESX or not ESX.UI then return end
            local elements = {}
            for _, opt in ipairs(registered.options or {}) do
                table.insert(elements, {
                    label = opt.title or opt.header or '',
                    value = opt.value or opt.args,
                    event = opt.event or (opt.params and opt.params.event),
                    args = opt.args or (opt.params and opt.params.args),
                    onSelect = opt.onSelect
                })
            end
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), id, {
                title = registered.title or registered.header or id,
                align = 'top-left',
                elements = elements
            }, function(data, m)
                if data.current.onSelect then
                    data.current.onSelect(data.current)
                elseif data.current.event then
                    TriggerEvent(data.current.event, data.current.args)
                end
            end, function(data, m)
                m.close()
            end)
        elseif menuType == 'esx_context' then
            if not registered then return end
            local elements = {}
            for _, opt in ipairs(registered.options or {}) do
                table.insert(elements, {
                    title = opt.title or opt.header,
                    description = opt.description or opt.txt,
                    icon = opt.icon,
                    action = function()
                        if opt.onSelect then
                            opt.onSelect(opt)
                        elseif opt.event or (opt.params and opt.params.event) then
                            TriggerEvent(opt.event or opt.params.event, opt.args or opt.params.args)
                        end
                    end
                })
            end
            exports['esx_context']:Open('right', elements)
        else
            print('^3[Dank_Utils] Menu: Unsupported or undetected menu system (' .. tostring(menuType) .. ') for show.^0')
        end
    end

    -- Close any open menu
    menu.close = function()
        local menuType = sharedConfig.Menu
        LogDebug(('[menu] close system=%s'):format(tostring(menuType)))
        if menuType == 'ox_lib' then
            if lib then lib.hideContext() end
        elseif menuType == 'qb-menu' then
            exports['qb-menu']:closeMenu()
        elseif menuType == 'esx_menu_default' then
            local ESX = exports['es_extended']:getSharedObject()
            if ESX and ESX.UI then ESX.UI.Menu.CloseAll() end
        elseif menuType == 'esx_context' then
            exports['esx_context']:Close()
        end
    end

    -- Open a menu directly on the fly
    ---@param id string
    ---@param title string
    ---@param elements table
    menu.open = function(id, title, elements)
        LogDebug(('[menu] open(id=%s, title=%s)'):format(tostring(id), tostring(title)))
        menu.register({
            id = id,
            title = title,
            options = elements
        })
        menu.show(id)
    end
end

return menu
