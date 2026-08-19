# Target · Menu · Keys

Reference for the `Dank.target`, `Dank.menu`, and `Dank.keys` modules.

## Target

`Dank.target` translates common targeting options for Ox Target, QB Target, and qtarget.

### Client API

| Function | Returns | Description |
|---|---|---|
| `Dank.target.addBoxZone(name, coords, size, options)` | adapter zone ID/result or `nil` | Adds a box zone using positional arguments. |
| `Dank.target.addBoxZone(options)` | adapter zone ID/result or `nil` | Adds a box zone using one options table. |
| `Dank.target.addCircleZone(options)` | `integer`, `string`, or `nil` | Adds a sphere/circle zone. |
| `Dank.target.addEntity(entity, options)` | adapter result or `nil` | Adds options to a local entity. |
| `Dank.target.addLocalEntity(entity, options)` | adapter result or `nil` | Alias of `addEntity`. |
| `Dank.target.addModel(model, options?)` | adapter result or `nil` | Adds options to one model or a model list. |
| `Dank.target.addGlobalVehicle(options)` | adapter result or `nil` | Adds options to every vehicle. |
| `Dank.target.addGlobalOption(options)` | adapter result or `nil` | Adds global options on Ox Target only. |
| `Dank.target.removeZone(zoneId)` | — | Removes a zone by its adapter ID or configured name. |
| `Dank.target.removeLocalEntity(entity)` | — | Removes targeting from a local entity. |
| `Dank.target.removeEntity(entity)` | — | Alias of `removeLocalEntity`. |

Adapter return values are forwarded, so retain the returned ID when the target system generates one.

### Target option shape

Options use Ox-style fields and are translated where possible:

```lua
{
    name = 'talk_clerk',
    icon = 'far fa-user',
    label = 'Talk to the clerk',
    event = 'cityhall:client:openMenu',
    args = { office = 'licenses' },
    groups = { police = 0 }
}
```

For QB Target and qtarget box, circle, entity, and model options, `groups` is copied to `job` when `job` is not already set, and `type` defaults to `'client'`.

### Box zones

```lua
local zoneId = Dank.target.addBoxZone(
    'cityhall_clerk',
    vec3(441.0, -982.0, 30.7),
    vec3(1.0, 1.0, 2.0),
    {
        rotation = 90.0,
        distance = 2.5,
        debugPoly = false,
        options = {
            {
                name = 'talk_clerk',
                icon = 'far fa-user',
                label = 'Talk to the clerk',
                event = 'cityhall:client:openMenu'
            }
        }
    }
)
```

The single-table form is equivalent:

```lua
local zoneId = Dank.target.addBoxZone({
    name = 'cityhall_clerk',
    coords = vec3(441.0, -982.0, 30.7),
    size = vec3(1.0, 1.0, 2.0),
    rotation = 90.0,
    distance = 2.5,
    options = {
        {
            name = 'talk_clerk',
            label = 'Talk to the clerk',
            event = 'cityhall:client:openMenu'
        }
    }
})
```

For QB Target and qtarget, vertical bounds are calculated from `coords.z` and `size.z`. Use a `vec3` size when exact height matters. If the single-table form has no name, a random `zone_<number>` name is generated.

### Circle zones

`options.options` may be one target option or an array of options; both shapes are normalized correctly.

```lua
local zoneId = Dank.target.addCircleZone({
    name = 'garage_terminal',
    coords = vec3(215.8, -810.1, 30.7),
    radius = 1.25,
    distance = 2.0,
    debugPoly = false,
    options = {
        name = 'open_garage',
        label = 'Open Garage',
        icon = 'fas fa-warehouse',
        event = 'garage:client:open'
    }
})
```

Invalid circle options or a missing `coords` field return `nil`.

### Entities, models, and global options

```lua
Dank.target.addEntity(vehicle, {
    {
        name = 'inspect_vehicle',
        label = 'Inspect vehicle',
        event = 'mechanic:client:inspect'
    }
})

Dank.target.addModel({ 'prop_atm_01', 'prop_atm_02' }, {
    {
        name = 'use_atm',
        label = 'Use ATM',
        event = 'banking:client:openAtm'
    }
})

Dank.target.addGlobalVehicle({
    {
        name = 'check_plate',
        label = 'Check plate',
        event = 'police:client:checkPlate'
    }
})
```

`addGlobalOption` is native to Ox Target. QB Target and qtarget print an unsupported-feature warning and return `nil`.

### Supported target systems

- `ox_target`
- `qb-target`
- `qtarget`

## Menu

`Dank.menu` stores a common context-menu definition and translates it when displayed.

### Client API

| Function | Description |
|---|---|
| `Dank.menu.register(menuData)` | Stores `{ id, title, options }` and registers an Ox context immediately when applicable. |
| `Dank.menu.show(id)` | Displays a previously registered menu. |
| `Dank.menu.open(id, title, elements)` | Registers and immediately displays a menu. |
| `Dank.menu.close()` | Closes the active menu when the adapter exposes a close operation. |

`register` requires a table with an `id`. Invalid input is logged and ignored.

### Menu and option fields

| Field | Description |
|---|---|
| `id` | Unique menu identifier. |
| `title` / `header` | Menu or option title. |
| `options` | Array of option tables. |
| `description` / `txt` | Secondary option text. |
| `icon`, `image`, `metadata`, `menu` | Adapter-specific presentation fields. |
| `event` | Event fired when selected. |
| `args` | Arguments forwarded directly to the event. |
| `onSelect` | Local callback used by supported adapters. |
| `type = 'server'` | Marks a QB Menu event as a server event. |
| `disabled`, `hidden` | QB Menu state controls. |
| `value` | ESX default-menu value. |

Legacy `params = { event, args, isServer }` fields remain supported. For QB Menu, event arguments are forwarded without extra nesting.

```lua
Dank.menu.register({
    id = 'vehicle_shop',
    title = 'Vehicle Shop',
    options = {
        {
            title = 'Buy a bike',
            description = '$500',
            event = 'shop:server:buyVehicle',
            type = 'server',
            args = { model = 'bmx', price = 500 }
        },
        {
            title = 'Preview car',
            onSelect = function()
                TriggerEvent('shop:client:preview', 'blista')
            end
        },
        {
            title = 'Unavailable',
            disabled = true
        }
    }
})

Dank.menu.show('vehicle_shop')
```

One-shot menus use the same option shape:

```lua
Dank.menu.open('city_hall', 'City Hall', {
    {
        title = 'Take a license test',
        icon = 'far fa-id-card',
        event = 'cityhall:client:startTest',
        args = { type = 'pilot' }
    }
})
```

### Adapter notes

| Adapter | Notable behavior |
|---|---|
| `ox_lib` | Supports context registration, `onSelect`, metadata, nested menus, and hide. |
| `qb-menu` | Supports client/server events, direct args, `onSelect` actions, disabled/hidden options, images, and close. |
| `nh-context` / `zf_context` | Supports local events and direct args. Explicit close is not implemented by this wrapper. |
| `esx_menu_default` | Supports values, local events, `onSelect`, and close-all. |
| `esx_context` | Supports local events, `onSelect`, and close. |

Presentation and control fields are forwarded only where the target adapter supports them.

## Keys

`Dank.keys` gives and removes vehicle access through the configured key resource.

### Shared API

| Function | Description |
|---|---|
| `Dank.keys.give(source, vehicle, plate?)` | Gives the player keys for a vehicle. |
| `Dank.keys.remove(source, vehicle, plate?)` | Removes the player's keys for a vehicle. |

`source` and `vehicle` are required. When `plate` is omitted and the vehicle entity exists, the module derives it with `GetVehicleNumberPlateText`.

```lua
-- server.lua
Dank.keys.give(source, vehicle)

-- Supplying a known plate remains supported.
Dank.keys.remove(source, vehicle, GetVehicleNumberPlateText(vehicle))
```

Server-side use is recommended. Client calls are implemented only for QB Vehicle Keys and still require non-nil `source` and `vehicle` arguments.

### Adapter coverage

| Resource | Give | Remove | Identifier used |
|---|:---:|:---:|---|
| `qbx_vehiclekeys` | ✓ | ✓ | Vehicle entity |
| `qb-vehiclekeys` | ✓ | ✓ | Plate |
| `wasabi_carlock` | ✓ | ✓ | Plate |
| `qs-vehiclekeys` | ✓ | ✓ | Plate |
| `mono_carlock` | ✓ | — | Plate |
| `tupani_carlock` | ✓ | ✓ | Plate |

When no key resource is configured, QBCore falls back to QB Vehicle Keys-style ownership events.

---

[Back to documentation index](../README.md)