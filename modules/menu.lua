local TriggerEvent = TriggerEvent
local exports = exports
local print = print
local tostring = tostring
local pairs = pairs
local table = table

local sharedConfig = require 'config.shared'
local menu = {}

if not IsDuplicityVersion() then
    -- CLIENT
    -- Abstracting opening a menu
    -- elements expects: { { title = string, description = string (optional), icon = string (optional), event = string, args = any (optional) } }
    menu.open = function(id, title, elements)
        local menuType = sharedConfig.Menu
        if menuType == 'ox_lib' then
            if not lib then print('^3[Dank_Utils] Menu: ox_lib not found.^0') return end
            local options = {}
            for _, el in pairs(elements) do
                table.insert(options, {
                    title = el.title,
                    description = el.description,
                    icon = el.icon,
                    event = el.event,
                    args = el.args
                })
            end
            lib.registerContext({
                id = id,
                title = title,
                options = options
            })
            lib.showContext(id)
        elseif menuType == 'qb-menu' then
            local menuData = {
                {
                    header = title,
                    isMenuHeader = true,
                }
            }
            for _, el in pairs(elements) do
                table.insert(menuData, {
                    header = el.title,
                    txt = el.description,
                    icon = el.icon,
                    params = {
                        event = el.event,
                        args = el.args
                    }
                })
            end
            exports['qb-menu']:openMenu(menuData)
        elseif menuType == 'nh-context' or menuType == 'zf_context' then
            local menuData = {
                {
                    header = title,
                    isMenuHeader = true
                }
            }
            for _, el in pairs(elements) do
                table.insert(menuData, {
                    header = el.title,
                    context = el.description,
                    event = el.event,
                    args = { el.args }
                })
            end
            if menuType == 'nh-context' then
                TriggerEvent('nh-context:sendMenu', menuData)
            else
                exports['zf_context']:openMenu(menuData)
            end
        elseif menuType == 'esx_menu_default' then
            local ESX = exports['es_extended']:getSharedObject()
            if not ESX then print('^3[Dank_Utils] Menu: ESX object not found for esx_menu_default.^0') return end
            local esxElements = {}
            for _, el in pairs(elements) do
                table.insert(esxElements, {
                    label = el.title,
                    value = el.args,
                    event = el.event
                })
            end
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), id, {
                title = title,
                align = 'top-left',
                elements = esxElements
            }, function(data, m)
                if data.current.event then
                    TriggerEvent(data.current.event, data.current.value)
                end
                m.close()
            end, function(data, m)
                m.close()
            end)
        else
            print('^3[Dank_Utils] Menu: Unsupported menu system ('..tostring(menuType)..') for open.^0')
        end
    end
end

return menu
