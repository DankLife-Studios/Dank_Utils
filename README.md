# Dank_Utils

Dank_Utils is a versatile, high-performance, **lazy-loaded** framework and utility library designed for FiveM, providing enhanced compatibility and functionality with various frameworks and systems. It seamlessly abstracts standard operations across frameworks, inventory systems, and banking systems.

## Table of Contents
- [Features](#features)
- [Supported Systems](#supported-systems)
- [Installation](#installation)
- [Configuration](#configuration)
- [Implementing in Your Scripts](#implementing-in-your-scripts)
- [Version Checking Integration](#version-checking-integration)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features

- **Lazy-Loaded Engine**: Dank_Utils acts as a true library. It only loads the specific modules you invoke into memory, ensuring zero overhead on your server.
- **Automatic Detection**: Automatically detects and selects active frameworks, inventory systems, and banking systems dynamically.
- **Unified API**: Exposes a clean, unified `Dank` global object to interact with multiple frameworks via the same syntax.
- **Framework Integration**: Supports popular frameworks like QB-Core, ESX, and QBX-Core.
- **Inventory System Support**: Integrates with various inventory systems such as OxInventory, QB Inventory, and more.
- **Banking System Compatibility**: Works with several banking systems including Renewed-Banking and OKOKBanking.
- **Built-in Version Checker**: Includes a reusable, dependency-free version checker function for all your scripts.

## Supported Systems

Dank_Utils supports automatic detection and integration with the following systems:

- **Frameworks**:
  - QB-Core
  - QBX-Core
  - ESX
  - ND_Core
  - ox_core

- **Inventory Systems**:
  - OxInventory
  - QB Inventory
  - PS Inventory
  - QS Inventory
  - ESX Inventory
  - core_inventory
  - chezza-inventory
  - codem-inventory

- **Banking Systems**:
  - PEFCL
  - Renewed-Banking
  - QB Management
  - OKOKBanking
  - QB Banking
  - ESX Jobbank
  - fd_banking

- **Target Systems**:
  - ox_target
  - qb-target
  - qtarget

- **Menu Systems**:
  - ox_lib
  - qb-menu
  - esx_menu_default
  - nh-context
  - zf_context

- **Phone Systems**:
  - lb-phone
  - qs-smartphone
  - qb-phone
  - gksphone
  - yseries (yphone)

## Installation

1. **Add to Your Server Resources**: Download or clone the `Dank_Utils` repository and place the `Dank_Utils` folder into your FiveM server's `resources` directory.

2. **Update `server.cfg`**: Open your `server.cfg` file and add the following line (make sure it's placed before the scripts that rely on it):
   ```lua
   ensure Dank_Utils 
   ```

## Configuration

The script automatically detects active frameworks, inventory systems, and banking systems. However, if you run multiple conflicting systems or want to force a specific one, you can do so in `config/manual.lua`.

Simply open `config/manual.lua` and uncomment the system you wish to force:
```lua
return {
    Debug = false,
    
    -- Uncomment ONE framework to force manual selection. Otherwise, leave commented for AutoDetect.
    -- Framework = 'qbx_core',
    Framework = 'qb-core', -- This will force qb-core
    -- Framework = 'es_extended',
}
```

## Implementing in Your Scripts

Since Dank_Utils is a lazy-loaded library, you don't use standard exports anymore.

1. In the `fxmanifest.lua` of your target script, add the `init.lua` to your shared scripts:
```lua
shared_scripts {
    '@Dank_Utils/init.lua',
    'config.lua',
    -- your other shared files
}
```

2. You now have access to the global `Dank` object in your script's client and server files!
```lua
-- Example: Fetch player data seamlessly
local player = Dank.player.get(source)

-- Example: Add money seamlessly
Dank.banking.addMoney(accountName, 500)
```
*Note: Ensure you add `F:/Mystic_Dreams/MysticDreams.base/resources/[dank]/Dank_Utils` to your VS Code `Lua.workspace.library` for full autocomplete!*

## Documentation (API Reference)

<details>
<summary><b>Dank.player</b> (Player Data & Management)</summary>

- `[Server]` **`Dank.player.get(source)`** - Returns the player object for the given source.
- `[Server]` **`Dank.player.getAll()`** - Returns a table of all active player objects on the server.
- `[Server]` **`Dank.player.getByCitizenId(citizenid)`** - Returns a player object by their citizen ID.
- `[Client]` **`Dank.player.getData()`** - Returns the local player's data table.
</details>

<details>
<summary><b>Dank.inventory</b> (Stashes, Items & Usage)</summary>

- `[Server]` **`Dank.inventory.addItem(source, item, amount)`** - Adds an item to a player's inventory.
- `[Server]` **`Dank.inventory.removeItem(source, item, amount)`** - Removes an item from a player's inventory.
- `[Server]` **`Dank.inventory.getItemByName(source, item)`** - Returns data for a specific item the player holds.
- `[Server]` **`Dank.inventory.createUseableItem(item, callback)`** - Registers a usable item and fires the callback.
- `[Server]` **`Dank.inventory.hasItem(source, item, amount)`** - Checks if a player has a specified amount of an item.
- `[Client]` **`Dank.inventory.openStash(stashName, maxweight, slots)`** - Opens a specific stash UI.
- `[Client]` **`Dank.inventory.getImageUrl()`** - Retrieves the root image URL path for the active inventory UI.
- `[Client]` **`Dank.inventory.hasItem(item, amount)`** - Checks if the local player has an item.
- `[Client]` **`Dank.inventory.hasItems(requiredItems)`** - Checks for multiple items `{[item] = count}`. Returns `true/false` and missing items.
- `[Client]` **`Dank.inventory.getItemLabel(itemName)`** - Retrieves the display label of an item name.
- `[Shared]` **`Dank.inventory.sharedItems(item)`** - Retrieves shared item configuration data.
</details>

<details>
<summary><b>Dank.ui</b> (Visuals & Interactions)</summary>

- `[Server]` **`Dank.ui.notify(source, message, type, time)`** - Sends a UI notification to a player.
- `[Client]` **`Dank.ui.notify(message, type, time)`** - Shows a local UI notification.
- `[Client]` **`Dank.ui.toggleDuty()`** - Toggles the local player's duty status.
- `[Client]` **`Dank.ui.progressbar(params)`** - Renders a progress bar with animations. Params: `{name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, onFinish, onCancel}`
</details>

<details>
<summary><b>Dank.vehicle</b> (Vehicle Utilities)</summary>

- `[Server]` **`Dank.vehicle.spawn(model, coords, heading, cb)`** - Spawns a vehicle server-side and returns it via callback.
- `[Client]` **`Dank.vehicle.getData(model)`** - Retrieves the configuration data for a vehicle model.
</details>

<details>
<summary><b>Dank.banking</b> (Economy Management)</summary>

- `[Server]` **`Dank.banking.getAccountBalance(account)`** - Returns the balance for a society or standard account.
- `[Server]` **`Dank.banking.addMoney(account, amount)`** - Deposits money into an account.
- `[Server]` **`Dank.banking.removeMoney(account, amount)`** - Withdraws money from an account.
</details>

<details>
<summary><b>Dank.core</b> (Core Overrides & Updates)</summary>

- `[Shared]` **`Dank.core.getFunctions()`** - Exposes raw framework functions if you need direct overrides.
- `[Server]` **`Dank.core.getJob(jobname)`** - Fetches the configuration for a specific job.
- `[Server]` **`Dank.core.getAllJobs()`** - Fetches all registered jobs.
- `[Server]` **`Dank.core.addCommand(name, description, args, restricted, callback, group)`** - Registers a framework-agnostic command.
- `[Server]` **`Dank.core.versionCheck(options)`** - Initializes the version checking loop.
</details>

<details>
<summary><b>Dank.phone</b> (Messaging & Communication)</summary>

- `[Server]` **`Dank.phone.sendEmail(source, data)`** - Sends an email. `data` table supports: `sender`, `subject`, `message`, `button` (optional table with `buttonEvent` and `buttonData`).
- `[Server]` **`Dank.phone.sendSMS(source, data)`** - Sends an SMS. `data` table supports: `number`, `message`.
</details>

<details>
<summary><b>Dank.target</b> (Third-Eye Interactions)</summary>

- `[Client]` **`Dank.target.addBoxZone(name, coords, size, options)`** - Registers a targeting box zone. `size` is a vector2/table (x,y). `options` table supports `rotation`, `debugPoly`, `distance`, and standard `options` array.
- `[Client]` **`Dank.target.addEntity(entity, options)`** - Registers an entity for targeting. `options` is a standard target options array.
</details>

<details>
<summary><b>Dank.menu</b> (Context Menus & UIs)</summary>

- `[Client]` **`Dank.menu.open(id, title, elements)`** - Opens a standardized context menu. `elements` is an array of tables supporting: `title`, `description` (optional), `icon` (optional), `event`, `args` (optional).
</details>

<br>

## Version Checking Integration

Dank_Utils provides a built-in, reusable version checker. Instead of duplicating version-checking scripts across all your resources, simply call this function on server start:

```lua
-- Inside your script's server.lua
CreateThread(function()
    Wait(1000) -- Small delay to ensure initialization
    
    if Dank and Dank.core and Dank.core.versionCheck then
        Dank.core.versionCheck("Dank_Bahama_Mama") -- The script name expected in the JSON
    end
end)
```

## Contributing

Contributions are welcome! If you have suggestions or improvements:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes and commit them (`git commit -am 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Create a new Pull Request.

## License

This project is licensed under the MIT License:

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

For more details, see the [LICENSE](LICENSE) file.

## Contact

For any questions or support, feel free to **join our community on Discord**:

[![Discord](https://img.shields.io/discord/976211208736763994?label=Join%20Discord&logo=discord&style=for-the-badge&color=blue)](https://discord.gg/4aW3gHFEs9)
