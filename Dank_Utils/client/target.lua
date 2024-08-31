-- @module Target
--- @desc A module that provides a unified interface for different target systems like qb-target and ox_target.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Target = Framework.Target or {}

if SharedConfig.Target == 'qb-target' then
    --- Add a box zone to the target system
    --- @param params table
    --- @param params.name string The name of the box zone
    --- @param params.coords vector3 The coordinates of the box zone center
    --- @param params.size vector3 The size of the box zone (width, height, depth)
    --- @param params.heading number The heading of the box zone
    --- @param params.minZ number The minimum Z coordinate for the box zone
    --- @param params.maxZ number The maximum Z coordinate for the box zone
    --- @param params.options table Options for the box zone (e.g., icon, label, event)
    --- @param params.options.type string Optional type of interaction (e.g., "client" or "server")
    --- @param params.options.icon string Optional icon for display
    --- @param params.options.label string Optional label for display
    --- @param params.options.onSelect function Optional function to execute when selected
    --- @param params.options.canInteract function Optional function to check interaction
    --- @param params.options.job string|table Optional job(s) required to interact
    --- @param params.options.gang string|table Optional gang(s) required to interact
    Framework.Target.AddBoxZone = function(params)
        local options = params.options or {}

        exports['qb-target']:AddBoxZone(params.name, params.coords, params.size.x, params.size.y, {
            heading = params.heading,
            minZ = params.minZ,
            maxZ = params.maxZ,
            debugPoly = params.debugPoly or false,
        }, {
            type = options.type or "client",
            icon = options.icon or 'fas fa-hand-holding-water',
            label = options.label or "Interact",
            action = options.onSelect or nil,  -- Correctly map onSelect to action
            canInteract = options.canInteract or nil,
            job = options.job or nil,
            gang = options.gang or nil
        })
    end

    --- Add a circle zone to the target system
    --- @param name string The name of the circle zone
    --- @param coords vector3 The coordinates of the circle zone center
    --- @param radius number The radius of the circle zone
    --- @param options table? Optional. Options for the circle zone
    --- @param options.num number? Optional numerical identifier or parameter
    --- @param options.type string? Optional type of interaction (e.g., "client" or "server")
    --- @param options.event string? Optional event name to trigger
    --- @param options.icon string? Optional icon for display
    --- @param options.label string? Optional label for display
    --- @param options.targeticon string? Optional icon for target display
    --- @param options.item string? Optional item associated with the zone
    --- @param options.onSelect function? Optional function to execute when the zone is interacted with
    --- @param options.canInteract function? Optional function to check if interaction is possible
    --- @param options.job string|table? Optional job(s) required to interact
    --- @param options.gang string|table? Optional gang(s) required to interact
    --- @param options.drawDistance number? Optional distance to draw the interaction (if supported)
    --- @param options.drawColor table? Optional color for drawing the zone (RGBA format)
    --- @param options.successDrawColor table? Optional color for successful interactions (RGBA format)
    Framework.Target.AddCircleZone = function(params)
        local options = params.options or {}
        exports['qb-target']:AddCircleZone(params.name, params.coords, params.radius, {
            type = options.type or "client",
            icon = options.icon or nil,
            debugPoly = options.debugPoly or false,
            label = options.label or "Interact",
            onSelect = options.onSelect or nil,
            canInteract = options.canInteract or nil,
            job = options.job or nil,
            gang = options.gang or nil,
            drawDistance = options.drawDistance or nil,
            drawColor = options.drawColor or nil,
            successDrawColor = options.successDrawColor or nil
        })
    end

    --- Add a target model to the target system
    --- @param model string The model name or hash
    --- @param options table Options for the target model (e.g., icon, label, event)
    Framework.Target.AddTargetModel = function(model, options)
        exports['qb-target']:AddTargetEntity(model, {
            options = {
                {
                    type = "client",
                    icon = options.icon or "fa-regular fa-comments",
                    label = options.label or "Interact",
                    action = options.onSelect,
                    canInteract = options.canInteract,
                }
            },
            distance = options.distance or 3.0
        })
    end

    --- Remove a zone from the target system
    --- @param name string The name of the zone to remove
    Framework.Target.RemoveZone = function(name)
        exports['qb-target']:RemoveZone(name)
    end

    Framework.Status.Target = SharedConfig.Target

elseif SharedConfig.Target == 'ox_target' then
    --- Add a box zone to the target system
    --- @param params table
    --- @param params.name string The name of the box zone
    --- @param params.coords vector3 The coordinates of the box zone center
    --- @param params.size vector3 The size of the box zone (width, height, depth)
    --- @param params.heading number The heading of the box zone
    --- @param params.minZ number The minimum Z coordinate for the box zone
    --- @param params.maxZ number The maximum Z coordinate for the box zone
    --- @param params.options table Options for the box zone (e.g., icon, label, event)
    Framework.Target.AddBoxZone = function(params)
        exports.ox_target:addBoxZone({
            name = params.name,
            coords = vec3(params.coords.x, params.coords.y, params.coords.z),
            size = vec3(params.size.x, params.size.y, params.size.z), -- Use params.size values
            rotation = params.heading, -- Use params.heading for rotation
            debug = params.debug or false, -- Set to false in production
            options = params.options -- Use params.options directly
        })
    end

    --- Add a circle zone to the target system
    --- @param params table
    --- @param params.name string The name of the circle zone
    --- @param params.coords vector3 The coordinates of the circle zone center
    --- @param params.radius number The radius of the circle zone
    --- @param params.options table? Optional. Options for the circle zone
    --- @param params.options.type string? Optional type of interaction (e.g., "client" or "server")
    --- @param params.options.event string? Optional event name to trigger
    --- @param params.options.icon string? Optional icon for display
    --- @param params.options.label string? Optional label for display
    --- @param params.options.targeticon string? Optional icon for target display
    --- @param params.options.item string? Optional item associated with the zone
    --- @param params.options.onSelect function? Optional function to execute when the zone is interacted with
    --- @param params.options.canInteract function? Optional function to check if interaction is possible
    --- @param params.options.job string|table? Optional job(s) required to interact
    --- @param params.options.gang string|table? Optional gang(s) required to interact
    --- @param params.options.drawDistance number? Optional distance to draw the interaction (if supported)
    --- @param params.options.drawColor table? Optional color for drawing the zone (RGBA format)
    --- @param params.options.successDrawColor table? Optional color for successful interactions (RGBA format)
    Framework.Target.AddCircleZone = function(params)
        local options = params.options or {}

        exports.ox_target:addSphereZone({
            coords = params.coords,
            radius = params.radius,
            debug = options.debug or false,
            drawSprite = options.drawSprite or false,
            options = {
                type = options.type or "client",
                icon = options.icon or nil,
                label = options.label or "Interact",
                onSelect = options.onSelect or nil,
                canInteract = options.canInteract or nil,
                job = options.job or nil,
                gang = options.gang or nil,
                drawDistance = options.drawDistance or nil,
                drawColor = options.drawColor or nil,
                successDrawColor = options.successDrawColor or nil
            }
        })
    end

    --- Add a target model to the target system
    --- @param model string|number|table The model name or hash, or a list of models
    --- @param options table Options for the target model (e.g., icon, label, event)
    Framework.Target.AddTargetModel = function(model, options)
        exports.ox_target:addModel(model, {
            name = options.name or 'target_option',
            label = options.label or "Interact",
            icon = options.icon or "fa-regular fa-comments",
            debug = options.debug or false,
            distance = options.distance or 3.0,
            onSelect = options.onSelect,
            canInteract = options.canInteract
        })
    end

    --- Remove a zone from the target system
    --- @param name string The name of the zone to remove
    Framework.Target.RemoveZone = function(name)
        exports.ox_target:RemoveZone(name)
    end

    Framework.Status.Target = SharedConfig.Target
end

return Framework
