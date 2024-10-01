Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Target = Framework.Target or {}

Framework.Target.AddBoxZone = function(params)
    if SharedConfig.Target == 'qb-target' then
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
    elseif SharedConfig.Target == 'ox_target' then
        exports.ox_target:addBoxZone({
            name = params.name,
            coords = vec3(params.coords.x, params.coords.y, params.coords.z),
            size = vec3(params.size.x, params.size.y, params.size.z), -- Use params.size values
            rotation = params.heading, -- Use params.heading for rotation
            debug = params.debug or false, -- Set to false in production
            options = params.options -- Use params.options directly
        })
    end
end

Framework.Target.AddCircleZone = function(params)
    local options = params.options or {}
    if SharedConfig.Target == 'qb-target' then
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
    elseif SharedConfig.Target == 'ox_target' then
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
end

Framework.Target.AddTargetModel = function(model, options)
    if SharedConfig.Target == 'qb-target' then
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
    elseif SharedConfig.Target == 'ox_target' then
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
end

Framework.Target.RemoveZone = function(name)
    if SharedConfig.Target == 'qb-target' then
        exports['qb-target']:RemoveZone(name)
    elseif SharedConfig.Target == 'ox_target' then
        exports.ox_target:RemoveZone(name)
    end
end

if SharedConfig.Target then
    Framework.Status.Target = SharedConfig.Target
end

return Framework