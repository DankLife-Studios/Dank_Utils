<div align="center">

# 🧰 Dank_Utils

**A lazy-loaded, framework-agnostic utility library for FiveM**

![GitHub Repo stars](https://img.shields.io/github/stars/DankLife-Studios/Dank_Utils?style=for-the-badge&color=yellow)
![GitHub forks](https://img.shields.io/github/forks/DankLife-Studios/Dank_Utils?style=for-the-badge&color=blue)
![GitHub issues](https://img.shields.io/github/issues/DankLife-Studios/Dank_Utils?style=for-the-badge&color=red)
![License](https://img.shields.io/badge/license-MIT-yellow?style=for-the-badge)
![Lua](https://img.shields.io/badge/Lua-5.4-blue?style=for-the-badge)
![Discord](https://img.shields.io/discord/976211208736763994?style=for-the-badge&logo=discord&logoColor=white&label=Discord&color=5865F2)

*Write once. Run on any framework.*

[Features](#features) · [Installation](#installation) · [API Reference](#api-reference) · [Contributing](#contributing) · [License](#license)

</div>

---

> **Dank_Utils** is a versatile, high-performance, **lazy-loaded** framework and utility library designed for FiveM. It abstracts the differences between popular frameworks, inventory systems, banking systems, and more — behind one clean, unified `Dank` API.

## Features

- ⚡ **Lazy-Loaded Engine** — Only loads modules when invoked, ensuring zero overhead.
- 🔍 **Automatic Detection** — Dynamically selects the active framework and systems.
- 🧩 **Unified API** — Consistent syntax across all modules.

## Installation

1. Place the `Dank_Utils` folder into your server's `resources` directory:

```lua
-- server.cfg
ensure Dank_Utils
```

2. Add the init file to any resource that uses the `Dank` global:

```lua
-- fxmanifest.lua
shared_scripts {
    '@Dank_Utils/init.lua',
}
```

> ⚠️ Make sure `ensure Dank_Utils` runs **before** any resource that uses the `Dank` global.

## Configuration

Force a specific framework in `config/dankutils_manual.lua`:

```lua
return {
    Debug = false,

    -- Uncomment ONE framework to force manual selection.
    -- Leave everything commented out for AutoDetect.
    Framework = 'qb-core',
}
```

## API Reference

| Module | Description |
|---|---|
| 🧍 [Player Management](docs/player-inventory-ui.md#dankplayer) | Player data, jobs, metadata, and money. |
| 🎒 [Inventory](docs/player-inventory-ui.md#dankinventory) | Items, stashes, and shops. |
| 🎨 [UI & Notifications](docs/player-inventory-ui.md#dankui) | Notifications, duty, and progress bars. |
| 🚗 [Vehicle Utilities](docs/vehicle-fuel-garage.md#dankvehicle) | Vehicle spawning and data. |
| ⛽ [Fuel Management](docs/vehicle-fuel-garage.md#dankfuel) | Set and read vehicle fuel. |
| 🏢 [Garage Management](docs/vehicle-fuel-garage.md#dankgarage) | Garages and vehicle state. |
| 🏦 [Banking](docs/banking-core-phone.md#dankbanking) | Society and account money. |
| 🧠 [Core & Utilities](docs/banking-core-phone.md#dankcore) | Raw framework access and version checking. |
| 📱 [Phone](docs/banking-core-phone.md#dankphone) | Emails and SMS. |
| 🎯 [Targeting](docs/target-menu-keys.md#danktarget) | Third-eye target zones and entities. |
| 📋 [Menus](docs/target-menu-keys.md#dankmenu) | Context menus. |
| 🔑 [Keys](docs/target-menu-keys.md#dankkeys) | Vehicle key management. |
| 🛡️ [Permissions](docs/permissions-debug.md#dankpermissions) | ACE and framework permission checks. |
| 🐛 [Debug](docs/permissions-debug.md#dankdebug) | Per-script debug logging. |

## Contributing

Contributions are welcome! Fork the repository, make your changes, and open a pull request.

## License

This project is licensed under the **MIT License** — see [LICENSE](https://github.com/DankLife-Studios/Dank_Utils/blob/Live/LICENSE).

---

<div align="center">

[![Discord](https://img.shields.io/discord/976211208736763994?style=for-the-badge&logo=discord&logoColor=white&label=Join%20Discord&color=5865F2)](https://discord.gg/4aW3gHFEs9)

</div>
