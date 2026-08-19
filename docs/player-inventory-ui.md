# Player · Inventory · UI

Reference for the `Dank.player`, `Dank.inventory`, and `Dank.ui` modules.

## Player

`Dank.player` normalizes common player, character, job, metadata, money, duty, and identifier operations across frameworks.

### Server API

| Function | Returns | Description |
|---|---|---|
| `Dank.player.get(source)` | `table` or `nil` | Returns the framework player object. |
| `Dank.player.getAll()` | `table` | Returns active players in the framework's native collection shape. |
| `Dank.player.getByCitizenId(citizenId)` | `table` or `nil` | Finds an online character and attempts an offline lookup when supported. |
| `Dank.player.getCharInfo(source)` | `table` | Returns normalized character information. |
| `Dank.player.setCharInfo(identifier, key, value)` | `boolean` | Updates a character field on Qbox or QBCore. |
| `Dank.player.getMetadata(source, key)` | any or `nil` | Reads one metadata value. |
| `Dank.player.setMetadata(source, key, value)` | `boolean` | Updates one metadata value. |
| `Dank.player.getJob(source)` | `table` | Returns a normalized job, including a safe unemployed fallback. |
| `Dank.player.setJob(source, jobName, gradeLevel)` | `boolean` | Sets the player's job and grade. |
| `Dank.player.getMoney(source, account)` | `number` | Returns an account balance, or `0` when unavailable. |
| `Dank.player.addMoney(source, account, amount, reason?)` | `boolean` | Adds a positive amount. |
| `Dank.player.removeMoney(source, account, amount, reason?)` | `boolean` | Removes a positive amount. |
| `Dank.player.isOnDuty(source)` | `boolean` | Returns the current duty state. |
| `Dank.player.getIdentifier(source)` | `string` or `nil` | Returns the framework character identifier. |

Money mutations reject missing, zero, and negative amounts. They also return `false` when the player or adapter operation is unavailable.

### Normalized data

`getCharInfo` always provides all five fields, using safe defaults when the player is missing:

```lua
{
    firstname = 'Alex',
    lastname = 'Morgan',
    birthdate = '1995-04-21',
    gender = 0,
    nationality = 'USA'
}
```

`getJob` uses this normalized shape:

```lua
{
    name = 'police',
    grade = {
        name = 'Officer',
        level = 2
    }
}
```

When no job is available, it returns `unemployed` at grade level `0` instead of `nil`.

### Server example

```lua
local player = Dank.player.get(source)
if not player then return end

local identifier = Dank.player.getIdentifier(source)
local charInfo = Dank.player.getCharInfo(source)
local job = Dank.player.getJob(source)

print(('%s %s (%s) works as %s')
    :format(charInfo.firstname, charInfo.lastname, identifier, job.name))

Dank.player.setMetadata(source, 'hunger', 100)
Dank.player.setJob(source, 'police', 2)

local paid = Dank.player.addMoney(source, 'bank', 500, 'Paycheck')
if not paid then
    print('Payment failed')
end
```

`setCharInfo` is currently implemented only for Qbox and QBCore. On other frameworks it returns `false`.

### Client API

| Function | Returns | Description |
|---|---|---|
| `Dank.player.getData()` | `table` | Returns local player data in the framework's native shape. |
| `Dank.player.getJob()` | `table` | Returns the normalized local job. |
| `Dank.player.isOnDuty()` | `boolean` | Returns the local duty state. |
| `Dank.player.getIdentifier()` | `string` or `nil` | Returns the local character identifier. |

```lua
local data = Dank.player.getData()
local job = Dank.player.getJob()
local identifier = Dank.player.getIdentifier()

print(('Character %s works as %s at grade %s')
    :format(identifier or 'unknown', job.name, job.grade.level))
```

Qbox reads `QBX.PlayerData` when available and safely falls back to the core export for compatibility.

### Supported frameworks

- Qbox (`qbx_core`)
- QBCore (`qb-core`)
- ESX (`es_extended`)
- ND Core (`ND_Core`)
- Ox Core (`ox_core`)

## Inventory

`Dank.inventory` provides common item operations and adapter-aware helpers for stashes, shops, drops, labels, and metadata.

### Server API

| Function | Returns | Description |
|---|---|---|
| `Dank.inventory.getInventoryItems(source)` | `table[]` | Returns the player's inventory items. |
| `Dank.inventory.addItem(source, item, amount, slot?, metadata?)` | `boolean` | Adds a positive amount. |
| `Dank.inventory.removeItem(source, item, amount, slot?, metadata?)` | `boolean` | Removes a positive amount. |
| `Dank.inventory.getItemByName(source, item)` | `table` or `nil` | Returns the first matching stack. |
| `Dank.inventory.getItemsByName(source, item)` | `table[]` | Returns every matching stack. |
| `Dank.inventory.getItemCount(source, item)` | `number` | Returns the total quantity across matching stacks. |
| `Dank.inventory.hasItem(source, item, amount?)` | `boolean` | Checks whether the player has at least the requested amount. |
| `Dank.inventory.canCarryItem(source, item, amount?)` | `boolean` | Checks capacity when the adapter supports it. |
| `Dank.inventory.setMetadata(source, slot, metadata)` | `boolean` | Replaces metadata for one inventory slot. |
| `Dank.inventory.createUseableItem(item, callback)` | — | Registers a usable item callback. |
| `Dank.inventory.getStashItems(stashId)` | `table[]` | Returns currently stored stash items when supported. |
| `Dank.inventory.registerStash(id, label, slots, weight, owner?, groups?, playerSource?)` | adapter result | Registers an Ox/Qbox or QS stash. |
| `Dank.inventory.registerShop(name, label, items, locations, groups?)` | — | Registers an Ox/Qbox shop. |
| `Dank.inventory.customDrop(id, items, coords)` | — | Creates an Ox/Qbox custom drop. |

Item amounts default to `1`; zero and negative values are rejected. QBCore item-box notifications are only emitted after a successful add or remove.

```lua
local added = Dank.inventory.addItem(source, 'water', 2, nil, {
    quality = 100
})

if added and Dank.inventory.hasItem(source, 'water', 1) then
    Dank.inventory.removeItem(source, 'water', 1)
end
```

### Usable items

```lua
Dank.inventory.createUseableItem('medkit', function(source, item, phase)
    if phase == 'usingItem' then
        -- Ox Inventory can cancel use when this callback returns false.
        return true
    end

    print(('Player %s used %s'):format(source, item.name))
end)
```

Ox Inventory supplies a third argument of `'usingItem'` or `'usedItem'`. Other frameworks call the same callback with `source` and `item` only.

### Stashes, shops, and drops

```lua
-- Ox Inventory / Qbox
Dank.inventory.registerStash(
    'police_locker',
    'Police Locker',
    50,
    1000000,
    nil,
    { police = 0 }
)
```

QS Inventory requires the player source as the seventh argument:

```lua
Dank.inventory.registerStash(
    'personal_locker',
    'Personal Locker',
    30,
    250000,
    nil,
    nil,
    source
)
```

`registerShop` and `customDrop` are Ox Inventory features. On Qbox, item, metadata, stash, shop, and drop operations are routed through Ox Inventory.

### Client API

| Function | Returns | Description |
|---|---|---|
| `Dank.inventory.openStash(stashName, maxWeight, slots)` | — | Opens a stash through the configured inventory UI. |
| `Dank.inventory.displayMetadata(metadata)` | — | Registers Ox Inventory metadata display labels. |
| `Dank.inventory.getImageUrl()` | `string` | Returns the active inventory's item image root. |
| `Dank.inventory.getItemsByName(item)` | `table[]` | Returns every local matching stack. |
| `Dank.inventory.getItemCount(item)` | `number` | Returns the local total item quantity. |
| `Dank.inventory.hasItem(item, amount?)` | `boolean` | Checks for one local item. |
| `Dank.inventory.hasItems(requiredItems)` | `boolean, table[]?` | Checks multiple items and reports missing quantities. |
| `Dank.inventory.getItemLabel(itemName)` | `string` | Returns the configured item label, falling back to the item name. |

`getItemCount` also accepts the older two-argument calling shape and locates the string item name for compatibility.

```lua
local ok, missing = Dank.inventory.hasItems({
    water = 2,
    sandwich = 1
})

if not ok then
    for _, entry in ipairs(missing) do
        print(('%s missing: %s'):format(entry.item, entry.missingAmount))
    end
end

Dank.inventory.openStash('police_locker', 1000000, 50)
```

Ox metadata labels can be registered before opening an inventory:

```lua
Dank.inventory.displayMetadata({
    serial = 'Serial number',
    registered = 'Registered owner'
})
```

### Shared API

| Function | Returns | Description |
|---|---|---|
| `Dank.inventory.sharedItems(item)` | `table` or `nil` | Returns one shared item definition from the active inventory/framework. |

### Adapter coverage

The inventory module has feature-level adapters; a listed inventory does not necessarily implement every server operation.

| Adapter | Main coverage |
|---|---|
| Ox Inventory / Qbox | Item queries and mutations, capacity, metadata, usable items, stashes, shops, drops, client queries, and labels. |
| QBCore inventories | Framework item queries and mutations, metadata, usable items, capacity, client queries; stash UI support varies by configured inventory. |
| ESX inventories | Framework item queries and mutations, usable items, capacity, and client queries; stash UI support varies. |
| QS Inventory | Item queries and mutations, capacity, metadata, stash read/register, client queries, and labels. |
| Origen Inventory | Item add/remove and client stash/image helpers. |
| PS, Core, Chezza, Codem, and ESX inventory UIs | Client stash and image helpers where implemented. |

Unsupported query helpers return safe defaults such as `{}`, `0`, `nil`, or `false`.

## UI

`Dank.ui` normalizes notifications, duty toggling, and progress bars.

### API

| Function | Scope | Description |
|---|:---:|---|
| `Dank.ui.notify(source, message, type?, duration?)` | Server | Sends a notification to one player. |
| `Dank.ui.notify(message, type?, duration?)` | Client | Shows a local notification. |
| `Dank.ui.toggleDuty()` | Client | Toggles the local player's duty state. |
| `Dank.ui.progressbar(params?)` | Client | Runs a progress bar and finish/cancel callbacks. |

Notification duration defaults to `5000` milliseconds and is forwarded to Qbox, QBCore, ESX, and Ox notifications. Without a supported notification adapter, chat is used as a fallback.

```lua
-- server.lua
Dank.ui.notify(source, 'You got paid!', 'success', 5000)
```

```lua
-- client.lua
Dank.ui.notify('Cleaning started', 'inform', 3000)
```

### Progress-bar parameters

| Field | Default | Description |
|---|---|---|
| `name` | `'progress'` | QBCore progress identifier. |
| `label` | `'Action'` | Text shown to the player. |
| `duration` | `5000` | Duration in milliseconds. |
| `useWhileDead` | `false` | Whether use is allowed while dead. |
| `canCancel` | `false` | Whether the player can cancel. |
| `disableControls` | `{}` | Control groups disabled while active. |
| `animation` | `{}` | Animation dictionary/clip options. |
| `prop` | `{}` | Prop options. |
| `onFinish` | no-op | Called after success. |
| `onCancel` | no-op | Called after cancellation. |

The parameter table is optional; safe defaults are applied when fields are missing.

```lua
Dank.ui.progressbar({
    name = 'cleaning',
    label = 'Cleaning the floor...',
    duration = 5000,
    canCancel = true,
    disableControls = { combat = true },
    animation = {
        dict = 'amb@prop_human_bum_bin@idle_a',
        clip = 'idle_a',
        flag = 49
    },
    onFinish = function()
        print('Done!')
    end,
    onCancel = function()
        print('Cancelled!')
    end
})
```

The module prefers `ox_lib` when its progress bar is available, then QBCore's progress API, then a timed fallback. The fallback completes after the requested duration and calls `onFinish`.

---

[Back to documentation index](../README.md)