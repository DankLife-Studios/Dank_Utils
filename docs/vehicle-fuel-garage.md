# 🚗 Vehicle · ⛽ Fuel · 🏢 Garage

## Dank.vehicle

> Seamless vehicle spawning with automatic plate generation, 100% fuel, and keys.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Server]` | `Dank.vehicle.spawn(source, model, coords, platePrefix, cb)` | Spawns a vehicle, sets fuel to 100, gives keys, and runs the callback. |
| `[Client]` | `Dank.vehicle.spawn(model, coords, platePrefix, cb)` | Requests a spawn through the server and returns the local entity. |
| `[Client]` | `Dank.vehicle.getData(model)` | Returns the configuration data for a vehicle model. |

> 📌 **Automatic extras** — every spawned vehicle gets a random 4-digit plate suffix (when `platePrefix` is a string), 100% fuel, and keys handed to the requesting player.

### Usage

```lua
-- Server
Dank.vehicle.spawn(source, 'police', vec4(441.0, -982.0, 30.7, 90.0), 'PD', function(veh)
    print(('Spawned vehicle with netId %s'):format(NetworkGetNetworkIdFromEntity(veh)))
end)
```

```lua
-- Client
Dank.vehicle.spawn('police', vec4(441.0, -982.0, 30.7, 90.0), 'PD', function(veh)
    SetVehicleEngineOn(veh, true, true, true)
end)

local data = Dank.vehicle.getData('police')
```

### Supported Frameworks

QB-Core · QBX-Core · ESX · ox_core (with native fallback for ND_Core / standalone)

---

## Dank.fuel

> Set and read fuel on any vehicle, regardless of the active fuel script.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Shared]` | `Dank.fuel.set(veh, level)` | Sets the fuel level (clamped to `0.0 – 100.0`). |
| `[Shared]` | `Dank.fuel.get(veh)` | Returns the current fuel level of a vehicle. |

> 📌 Both functions work on **server and client**. On the server, legacy fuel scripts are handled by forwarding the call to the vehicle owner's client.

### Usage

```lua
-- Works on server and client
Dank.fuel.set(vehicle, 100.0)
local fuel = Dank.fuel.get(vehicle)
```

### Supported Fuel Scripts

ox_fuel · cdn-fuel · ti_fuel · LegacyFuel · lj-fuel · ps-fuel

Falls back to the native `SetVehicleFuelLevel` / `GetVehicleFuelLevel` when no fuel script is detected.

---

## Dank.garage

> Garage and vehicle state management with safe wrappers around popular garage scripts.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Server]` | `Dank.garage.registerOutside(plate, netId, model?, garageId?)` | Registers a spawned vehicle as being outside a garage. |
| `[Server]` | `Dank.garage.deleteOutside(plate)` | Removes the outside / spawned state for a plate. |
| `[Server]` | `Dank.garage.storeVehicle(source, vehicleEntity, garageId?)` | Stores a vehicle into a garage. |
| `[Server]` | `Dank.garage.impoundVehicle(plate, impoundName?, reason?, fee?)` | Impounds a vehicle by plate. |
| `[Server]` | `Dank.garage.getVehicleState(plate, cb)` | Queries the vehicle state and passes it to the callback. |
| `[Server]` | `Dank.garage.getAllGarages()` | Returns all registered garage locations and metadata. |
| `[Client]` | `Dank.garage.registerOutside(plate, netId, model?, garageId?)` | Client-side outside registration. |
| `[Client]` | `Dank.garage.deleteOutside(plate)` | Client-side outside removal. |
| `[Client]` | `Dank.garage.storeVehicle(vehicleEntity?, garageId?)` | Client-side vehicle storage. |

### Vehicle States

| Value | State |
|:---:|---|
| `0` | Outside |
| `1` | Stored |
| `2` | Impounded |

### Usage

```lua
-- Server
Dank.garage.registerOutside('ABC123', netId, 'adder', 'main')

Dank.garage.getVehicleState('ABC123', function(state)
    if state == 1 then
        print('Vehicle is stored in a garage')
    end
end)

Dank.garage.impoundVehicle('ABC123', 'lspd_impound', 'Illegal parking', 500)
```

```lua
-- Client
Dank.garage.storeVehicle(nil, 'main') -- stores the vehicle the player is in
```

### Supported Garage Systems

jg-advancedgarages · qb-garages · cd_garage · okokGarage · rcore_garage · qs-advancedgarages · esx_garage

---

[← Back to README](../README.md)
