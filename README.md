# Dank_Utils

Dank_Utils is a versatile framework and utility script designed for FiveM, providing enhanced compatibility and functionality with various frameworks and systems. It includes automatic detection for supported frameworks, inventory systems, and banking systems.

## Dependencies

Dank_Utils requires the following dependency:

- **ox_lib**: This library is essential for Dank_Utils to function properly. You can find it at [https://github.com/overextended/ox_lib](https://github.com/overextended/ox_lib)

Make sure to install and configure ox_lib before using Dank_Utils.

## Table of Contents
- [Features](#features)
- [Supported Systems](#supported-systems)
- [Installation](#installation)
- [Configuration](#configuration)
- [Missing Components](#missing-components)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features

- **Automatic Detection**: Automatically detects and selects active frameworks, inventory systems, and banking systems.
- **Framework Integration**: Supports popular frameworks like QB-Core, ESX, and others.
- **Inventory System Support**: Integrates with various inventory systems such as OxInventory, QB Inventory, and more.
- **Banking System Compatibility**: Works with several banking systems including Renewed-Banking and OKOKBanking.
- **Flexible Configuration**: Allows manual selection of preferred systems if auto-detection is not needed.
- **Professional Messaging**: Alerts users if any supported components are missing and provides guidance for resolution.

## Supported Systems

Dank_Utils supports automatic detection and integration with the following systems:

- **Frameworks**:
  - QB-Core
  - QBX-Core
  - ESX -- NEEDS SOMEONE TO TEST THIS!!

- **Inventory Systems**:
  - OxInventory
  - QB Inventory
  - PS Inventory
  - QS Inventory
  - ESX Inventory -- NEEDS SOMEONE TO TEST THIS!!

- **Banking Systems**:
  - Renewed-Banking
  - QB Management
  - OKOKBanking
  - QB Banking
  - ESX Jobbank -- NEEDS SOMEONE TO TEST THIS!!

## Installation

1. **Add to Your Server Resources**: Download or clone the `Dank_Utils` repository and place the `Dank_Utils` folder into your FiveM server's `resources` directory.

2. **Update `server.cfg`**: Ensure the Dank_Utils resource is started before any other resource that depends on it. Open your `server.cfg` file and add the following line:

  ```lua
  ensure Dank_Utils 
  ```

3. **IF YOU USE QBCORE - You can add this to your `server.cfg` file, if you want to force the use of Qb-menu instead of Ox_lib menu.

  ```lua
  # QBCore UseTarget
  setr ForceUseQbMenu true
  ```

4. **Configure Dependencies**: Update the `fxmanifest.lua` file by **following the instructions** provided within the file. **Uncomment** lines for frameworks or scripts you are using (remove the `--` at the beginning of the line). **Comment out** lines for frameworks or libraries you are not using (add `--` at the start of the line) or keep them commented.

Here is an example illustrating how to configure your `fxmanifest.lua`:

```lua
fx_version 'cerulean'
game 'gta5'

name 'Dank_Utils'
author 'Dankbudbaker'
description 'A Framework & Script Compatibility For DankLife Scripts'
script_version '0.4.1'

-- **INSTRUCTIONS:**
-- If you DO NOT use the framework or library mentioned, add or keep `--` at the start of the line to disable it.
-- If you USE the framework, ensure there is no `--` at the beginning of the line.

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua', -- DISABLE THIS LINE IF YOU DON'T USE qbx_core (Keep or add --)
    'config/shared.lua',
    'shared/exports.lua'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua', -- DISABLE THIS LINE IF YOU DON'T USE qbx_core (Keep or add --)
    'config/shared.lua',
    'client/framework.lua',
    'client/inventory.lua',
    'client/banking.lua',
    'client/target.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/shared.lua',
    'server/framework.lua',
    'server/inventory.lua',
    'server/banking.lua',
    'server/target.lua',
    'server/version.lua'
}

escrow_ignore {
    'shared/**',
    'client/**',
    'server/**'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
```
5. Add This to access the Framework

```Lua
local Framework = exports['Dank_Utils'].Framework()
```

6. Restart Your Server: After making these changes, restart your FiveM server to apply the configuration.

## Configuration

The script automatically detects active frameworks, inventory systems, and banking systems. You can manually specify preferred systems by editing the `manualSelection` table in your configuration. For detailed configuration instructions, refer to the `config/shared.lua` file.

## Missing Components

If any supported components are missing, the script will alert you with a professional message. Ensure that the required systems are correctly installed and started.

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
