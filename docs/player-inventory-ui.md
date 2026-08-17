# 🧍 Player · 🎒 Inventory · 🎨 UI

## Dank.player

> Framework-agnostic player data, jobs, metadata, and money management for the local and remote player.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Server]` | `Dank.player.get(source)` | Returns the player object for the given source. |
| `[Server]` | `Dank.player.getAll()` | Returns a table of all active player objects. |
| `[Server]` | `Dank.player.getByCitizenId(citizenid)` | Returns a player by citizen ID (tries offline players as fallback). |
| `[Server]` | `Dank.player.getCharInfo(source)` | Returns a normalized `{ firstname, lastname }` table. |
| `[Server]` | `Dank.player.setCharInfo(identifier, key, value)` | Updates a character-info field for a player. |
| `[Server]` | `Dank.player.getMetadata(source, key)` | Returns a metadata value for a player. |
| `[Server]` | `Dank.player.setMetadata(source, key, value)` | Sets a metadata value for a player. |
| `[Server]` | `Dank.player.getJob(source)` | Returns a normalized `{ name, grade }` job table. |
| `[Server]` | `Dank.player.setJob(source, jobName, gradeLevel)` | Sets the player's job and grade level. |
| `[Server]` | `Dank.player.getMoney(source, account)` | Gets the player's money for an account (`'cash'`, `'bank'`, or custom). |
| `[Server]` | `Dank.player.addMoney(source, account, amount, reason)` | Adds money to an account. |
| `[Server]` | `Dank.player.removeMoney(source, account, amount, reason)` | Removes money from an account. |
| `[Server]` | `Dank.player.isOnDuty(source)` | Returns the player's duty status. |
| `[Client]` | `Dank.player.getData()` | Returns the local player's data table. |
| `[Client]` | `Dank.player.getJob()` | Returns the local player's normalized job table. |
| `[Client]` | `Dank.player.isOnDuty()` | Returns the local player's duty status. |

> 📌 **Normalized job shape** — `getJob` returns the same structure on every framework:
>
> ```lua
> { name = 'police', grade = { name = 'Officer', level = 2 } }
> ```

### Usage

```lua
-- Server
local player = Dank.player.get(source)

Dank.player.setMetadata(source, 'hunger', 100)
local hunger = Dank.player.getMetadata(source, 'hunger')

Dank.player.setJob(source, 'police', 2)

Dank.player.addMoney(source, 'bank', 500, 'Paycheck')
Dank.player.removeMoney(source, 'cash', 50, 'Ticket')
```

```lua
-- Client
local data = Dank.player.getData()
local job  = Dank.player.getJob()

print(('You work as %s (grade %s)'):format(job.name, job.grade.name))
```

### Supported Frameworks

QB-Core · QBX-Core · ESX · ND_Core · ox_core

---

## Dank.inventory

> Unified items, stashes, and shops API across 8+ inventory systems.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Server]` | `Dank.inventory.getInventoryItems(source)` | Returns all items in the player's inventory. |
| `[Server]` | `Dank.inventory.addItem(source, item, amount, slot?, metadata?)` | Adds an item to the player's inventory. |
| `[Server]` | `Dank.inventory.removeItem(source, item, amount, slot?, metadata?)` | Removes an item from the player's inventory. |
| `[Server]` | `Dank.inventory.getItemByName(source, item)` | Returns data for a specific item the player holds. |
| `[Server]` | `Dank.inventory.getItemsByName(source, item)` | Returns all stack entries matching the item name. |
| `[Server]` | `Dank.inventory.getItemCount(source, item)` | Returns the total count of an item. |
| `[Server]` | `Dank.inventory.hasItem(source, item, amount)` | Checks if a player has the specified amount. |
| `[Server]` | `Dank.inventory.canCarryItem(source, item, amount)` | Checks if a player can carry the specified amount. |
| `[Server]` | `Dank.inventory.setMetadata(source, slot, metadata)` | Updates the metadata of an item slot. |
| `[Server]` | `Dank.inventory.createUseableItem(item, callback)` | Registers a usable item and fires the callback on use. |
| `[Server]` | `Dank.inventory.getStashItems(stashId)` | Returns the items stored in a stash. |
| `[Server]` | `Dank.inventory.registerStash(id, label, slots, weight, owner?, groups?)` | Registers a stash with the active inventory. |
| `[Server]` | `Dank.inventory.registerShop(name, label, items, locations, groups?)` | Registers a shop with the active inventory. |
| `[Server]` | `Dank.inventory.customDrop(id, items, coords)` | Drops items via the active inventory's custom drop. |
| `[Client]` | `Dank.inventory.openStash(stashName, maxweight, slots)` | Opens a specific stash UI. |
| `[Client]` | `Dank.inventory.getImageUrl()` | Returns the root image URL for the active inventory UI. |
| `[Client]` | `Dank.inventory.getItemsByName(item)` | Returns all entries matching the item name for the local player. |
| `[Client]` | `Dank.inventory.getItemCount(item)` | Returns the total count of an item for the local player. |
| `[Client]` | `Dank.inventory.hasItem(item, amount)` | Checks if the local player has an item. |
| `[Client]` | `Dank.inventory.hasItems(requiredItems)` | Checks for multiple items `{[item] = count}`. Returns `ok, missingItems`. |
| `[Client]` | `Dank.inventory.getItemLabel(itemName)` | Returns the display label of an item. |
| `[Shared]` | `Dank.inventory.sharedItems(item)` | Returns shared item configuration data. |

> 📌 **Client vs Server signatures** — client functions have no `source` argument; they always operate on the local player.

### Usage

```lua
-- Server
Dank.inventory.addItem(source, 'water', 2)

if Dank.inventory.hasItem(source, 'water', 1) then
    Dank.inventory.removeItem(source, 'water', 1)
end

Dank.inventory.createUseableItem('medkit', function(source, item)
    print(('Player %s used %s'):format(source, item.name))
end)

Dank.inventory.registerStash('police_locker', 'Police Locker', 50, 1000000)
```

```lua
-- Client
local hasWater = Dank.inventory.hasItem('water', 1)

local badges = Dank.inventory.getItemsByName('police_badge')
for _, item in pairs(badges) do
    print(('Slot %s — count %s'):format(item.slot, item.count))
end

Dank.inventory.openStash('police_locker', 1000000, 50)
```

### Supported Inventory Systems

OxInventory · QB Inventory · PS Inventory · QS Inventory · ESX Inventory · core_inventory · chezza-inventory · codem-inventory · origen_inventory

---

## Dank.ui

> Notifications, duty toggling, and progress bars — unified across frameworks.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Server]` | `Dank.ui.notify(source, message, type?, time?)` | Sends a notification to a player. |
| `[Client]` | `Dank.ui.notify(message, type?, time?)` | Shows a local notification. |
| `[Client]` | `Dank.ui.toggleDuty()` | Toggles duty for the local player. |
| `[Client]` | `Dank.ui.progressbar(params)` | Renders an animated progress bar. |

> 📌 **Notification types** — pass framework-agnostic types such as `'success'`, `'error'`, `'inform'`, or `'primary'`; they are forwarded to the active framework untouched.

### Usage

```lua
-- Server
Dank.ui.notify(source, 'You got paid!', 'success', 5000)
```

```lua
-- Client
Dank.ui.notify('Cleaning started', 'inform')

Dank.ui.progressbar({
    name            = 'cleaning',
    label           = 'Cleaning the floor...',
    duration        = 5000,
    useWhileDead    = false,
    canCancel       = true,
    disableControls = { combat = true },
    animation       = { dict = 'amb@prop_human_bum_bin@idle_a', clip = 'idle_a', flag = 49 },
    onFinish        = function() print('Done!') end,
    onCancel        = function() print('Cancelled!') end,
})
```

> 💡 With `ox_lib` available, `progressbar` uses `lib.progressBar` (its return value decides finish/cancel). On QB-Core it uses `Functions.Progressbar`, and elsewhere it falls back to a timed wait.

### Supported Frameworks

QB-Core · QBX-Core · ESX · ND_Core · ox_core

---

[← Back to README](../README.md)
