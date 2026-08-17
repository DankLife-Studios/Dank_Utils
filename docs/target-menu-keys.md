# 🎯 Target · 📋 Menu · 🔑 Keys

## Dank.target

> Third-eye targeting zones and entities across ox_target, qb-target, and qtarget.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Client]` | `Dank.target.addBoxZone(name\|table, coords?, size?, options?)` | Registers a box zone. Accepts either positional args or a single options table. |
| `[Client]` | `Dank.target.addCircleZone(options)` | Registers a circular zone: `{ name, coords, radius, options, debugPoly }`. |
| `[Client]` | `Dank.target.addEntity(entity, options)` | Registers an entity for targeting. |
| `[Client]` | `Dank.target.addLocalEntity(entity, options)` | Alias of `addEntity`. |
| `[Client]` | `Dank.target.addModel(model, options)` | Registers a model (or model list) for targeting. |
| `[Client]` | `Dank.target.removeZone(zoneId)` | Removes a zone by name. |
| `[Client]` | `Dank.target.removeLocalEntity(entity)` | Removes targeting from an entity. |
| `[Client]` | `Dank.target.removeEntity(entity)` | Alias of `removeLocalEntity`. |
| `[Client]` | `Dank.target.addGlobalVehicle(options)` | Registers global vehicle targeting options. |
| `[Client]` | `Dank.target.addGlobalOption(options)` | Registers global targeting options (ox_target only). |

> 📌 Options use ox_target conventions (`name`, `icon`, `label`, `event`, `groups`, ...) and are translated automatically for qb-target / qtarget.

### Usage

```lua
-- Client
Dank.target.addBoxZone('cityhall_clerk', vec3(441.0, -982.0, 30.7), vec2(1.0, 1.0), {
    rotation = 90.0,
    distance = 2.5,
    options  = {
        {
            name  = 'talk_clerk',
            icon  = 'far fa-user',
            label = 'Talk to the clerk',
            event = 'cityhall:client:openMenu',
        },
    },
})

-- Single-table form (same result)
Dank.target.addBoxZone({
    name    = 'cityhall_clerk',
    coords  = vec3(441.0, -982.0, 30.7),
    size    = vec2(1.0, 1.0),
    options = { { name = 'talk_clerk', event = 'cityhall:client:openMenu' } },
})

Dank.target.removeZone('cityhall_clerk')
```

### Supported Target Systems

ox_target · qb-target · qtarget

---

## Dank.menu

> Context menus across ox_lib, qb-menu, nh-context, zf_context, esx_menu_default, and esx_context.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Client]` | `Dank.menu.register(menuData)` | Registers a menu definition: `{ id, title, options }`. |
| `[Client]` | `Dank.menu.show(id)` | Shows a previously registered menu by ID. |
| `[Client]` | `Dank.menu.close()` | Closes any open menu. |
| `[Client]` | `Dank.menu.open(id, title, elements)` | Registers and immediately opens a menu on the fly. |

> 📌 **Option fields** — `title`, `description`, `icon`, `image`, `event`, `args`, `onSelect` (and `value` for esx_menu_default). The fields are translated to each menu system automatically.

### Usage

```lua
-- Client: one-shot menu
Dank.menu.open('main_menu', 'City Hall', {
    {
        title = 'Take a license test',
        icon  = 'far fa-id-card',
        event = 'cityhall:client:startTest',
        args  = { type = 'pilot' },
    },
    {
        title       = 'Pick up a card',
        description = 'Requires a completed test',
        event       = 'cityhall:client:pickupCard',
    },
})
```

```lua
-- Client: register once, show many times
Dank.menu.register({
    id      = 'vehicle_shop',
    title   = 'Vehicle Shop',
    options = {
        { title = 'Buy a bike',  event = 'shop:client:buyBike' },
        { title = 'Buy a car',   event = 'shop:client:buyCar' },
    },
})

Dank.menu.show('vehicle_shop')
Dank.menu.close()
```

### Supported Menu Systems

ox_lib · qb-menu · nh-context · zf_context · esx_menu_default · esx_context

---

## Dank.keys

> Vehicle key management abstracted across the popular key systems.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Shared]` | `Dank.keys.give(source, veh, plate)` | Gives keys for a vehicle to a player. |
| `[Shared]` | `Dank.keys.remove(source, veh, plate)` | Removes keys for a vehicle from a player. |

> 📌 On the server, keys are routed through the active key script. The client variants only act for `qb-vehiclekeys` via local events.

### Usage

```lua
-- Server
local plate = GetVehicleNumberPlateText(vehicle)

Dank.keys.give(source, vehicle, plate)
Dank.keys.remove(source, vehicle, plate)
```

### Supported Key Systems

qbx_vehiclekeys · qb-vehiclekeys · wasabi_carlock · qs-vehiclekeys · mono_carlock · tupani_carlock

---

[← Back to README](../README.md)
