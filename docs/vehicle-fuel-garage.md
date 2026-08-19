# Vehicle · Fuel · Garage

Reference for the `Dank.vehicle`, `Dank.fuel`, and `Dank.garage` modules.

## Vehicle

`Dank.vehicle` spawns networked vehicles and applies the common post-spawn setup: an optional generated plate, full fuel, and keys for the requesting player.

### API

| Function | Scope | Description |
|---|:---:|---|
| `Dank.vehicle.spawn(source, model, coords, platePrefix?, callback?)` | Server | Spawns a vehicle and calls `callback(vehicle)` or `callback(nil)`. |
| `Dank.vehicle.spawn(model, coords, platePrefix?, callback?)` | Client | Requests a server spawn and calls `callback(vehicle)` or `callback(nil)`. |
| `Dank.vehicle.getData(model)` | Client | Returns framework vehicle configuration data, or `nil`. |

`model` may be a model name or hash. `coords` must provide `x`, `y`, and `z`; `w` is used as the heading when present.

### Spawn behavior

After the entity is created successfully, the module:

1. Applies `<platePrefix><random 4 digits>` when `platePrefix` is a string.
2. Sets fuel to `100.0` through `Dank.fuel`.
3. Gives keys when the server received a valid player source.
4. Calls the callback with the vehicle entity.

Every failure path now resolves the callback with `nil`; consumers should always guard the entity.

```lua
-- server.lua
Dank.vehicle.spawn(
    source,
    'police',
    vec4(441.0, -982.0, 30.7, 90.0),
    'PD',
    function(vehicle)
        if not vehicle or not DoesEntityExist(vehicle) then
            print('Vehicle spawn failed')
            return
        end

        print(('Spawned network ID %s')
            :format(NetworkGetNetworkIdFromEntity(vehicle)))
    end
)
```

```lua
-- client.lua
Dank.vehicle.spawn(
    'police',
    vec4(441.0, -982.0, 30.7, 90.0),
    'PD',
    function(vehicle)
        if not vehicle then
            Dank.ui.notify('Vehicle spawn failed', 'error')
            return
        end

        -- The client helper starts the engine before this callback.
        SetVehicleDirtLevel(vehicle, 0.0)
    end
)

local data = Dank.vehicle.getData('police')
```

`getData` is implemented for Qbox, QBCore, and Ox Core. It returns `nil` on other frameworks.

### Spawn backends

- Qbox (`qbx_core`)
- QBCore (`qb-core`)
- ESX (`es_extended`)
- Ox Core (`ox_core`)
- Native server spawning for ND Core and standalone configurations

## Fuel

`Dank.fuel` reads and writes clamped vehicle fuel levels from either side of the network.

### Shared API

| Function | Returns | Description |
|---|---|---|
| `Dank.fuel.set(vehicle, level)` | — | Sets fuel between `0.0` and `100.0`. Invalid/non-numeric levels default to `100.0`. |
| `Dank.fuel.get(vehicle)` | `number` | Returns the current fuel level. Invalid entities return `0.0`. |

```lua
Dank.fuel.set(vehicle, 75.5)

local level = Dank.fuel.get(vehicle)
print(('Fuel: %.1f%%'):format(level))
```

### Server behavior

Every server-side write updates `Entity(vehicle).state.fuel`, regardless of the selected fuel resource. This keeps a replicated source of truth available to other scripts.

For legacy client-owned fuel resources, the module also forwards the update to the entity owner's client when an owner and network ID are available. If no owner is available, the state-bag value is still retained.

Server reads use the state bag and default to `100.0` when it has no value.

### Client behavior

The client uses the configured fuel adapter. When none is detected, it falls back to the FiveM fuel natives.

| Resource | Set | Get |
|---|:---:|:---:|
| `ox_fuel` | State bag | State bag, then native fallback |
| `cdn-fuel` | Export | Export |
| `ti_fuel` | Event | Decorator, then native fallback |
| `LegacyFuel` | Export | Export |
| `lj-fuel` | Export | Export |
| `ps-fuel` | Export | Export |
| None/unsupported | Native | Native |

## Garage

`Dank.garage` wraps outside-state, storage, impound, vehicle-state, and garage-list operations for supported garage resources.

### Server API

| Function | Returns | Description |
|---|---|---|
| `Dank.garage.registerOutside(plate, netId, model?, garageId?)` | — | Marks a spawned vehicle as outside. |
| `Dank.garage.deleteOutside(plate)` | — | Removes outside status or marks the vehicle stored. |
| `Dank.garage.storeVehicle(source, vehicleEntity, garageId?)` | — | Invokes the configured store operation. |
| `Dank.garage.impoundVehicle(plate, impoundName?, reason?, fee?)` | — | Invokes the configured impound operation. |
| `Dank.garage.getVehicleState(plate, callback)` | — | Passes a DB-backed state to `callback(state)`. |
| `Dank.garage.getAllGarages()` | `table[]` | Returns adapter garage definitions, or `{}`. |

### Client API

| Function | Description |
|---|---|
| `Dank.garage.registerOutside(plate, netId, model?, garageId?)` | Registers outside state on supported client adapters. |
| `Dank.garage.deleteOutside(plate)` | Deletes outside state on supported client adapters. |
| `Dank.garage.storeVehicle(vehicleEntity?, garageId?)` | Stores the supplied vehicle or the vehicle the player is currently driving. |
| `Dank.garage.impoundVehicle(plate, impoundName?, reason?, fee?)` | Opens/triggers a supported client impound flow. |

### Vehicle states

For QBCore/Qbox and ESX database queries, states are normalized as:

| Value | Meaning |
|:---:|---|
| `0` | Outside |
| `1` | Stored |
| `2` | Impounded |

`getVehicleState` queries `player_vehicles.state` on QBCore/Qbox and `owned_vehicles.stored` on ESX. Other frameworks receive `0`. The callback is required.

```lua
Dank.garage.registerOutside('ABC123', netId, 'adder', 'main')

Dank.garage.getVehicleState('ABC123', function(state)
    if state == 1 then
        print('Vehicle is stored')
    elseif state == 2 then
        print('Vehicle is impounded')
    end
end)

Dank.garage.impoundVehicle(
    'ABC123',
    'lspd_impound',
    'Illegal parking',
    500
)
```

```lua
-- client.lua: nil selects the vehicle occupied by the player.
Dank.garage.storeVehicle(nil, 'main')
```

### Adapter coverage

Garage resources expose different feature sets. The wrapper calls only operations implemented for each adapter.

| Resource | Outside state | Store | Impound | Garage list |
|---|:---:|:---:|:---:|:---:|
| `jg-advancedgarages` | ✓ | ✓ | ✓ | ✓ |
| `qb-garages` | DB/server | ✓ | ✓ | ✓ when export exists |
| `cd_garage` | — | ✓ | ✓ | ✓ |
| `okokGarage` | ✓ | ✓ | ✓ | ✓ |
| `rcore_garage` | ✓ | ✓ | ✓ | — |
| `qs-advancedgarages` | ✓ | ✓ | — | ✓ when export exists |
| `qs-garage` | ✓ | ✓ | — | ✓ when export exists |
| `esx_garage` | DB/server | — | DB/server | — |

Both QS names use their configured resource name; no hardcoded alias is substituted.

Garage adapter calls are protected. An adapter exception is sent to debug logging instead of crashing the calling resource. Because these helpers do not return success booleans, use the target garage's state/event flow when you need operation confirmation.

---

[Back to documentation index](../README.md)