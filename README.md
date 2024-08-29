# Dank_Utils

Dank_Utils is a versatile framework and utility script designed for FiveM, providing enhanced compatibility and functionality with various frameworks and systems. It includes automatic detection for supported frameworks, inventory systems, and banking systems.

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
  - ESX
  - QBX-Core

- **Inventory Systems**:
  - OxInventory
  - QB Inventory
  - PS Inventory
  - QS Inventory
  - ESX Inventory

- **Banking Systems**:
  - Renewed-Banking
  - QB Management
  - OKOKBanking
  - QB Banking
  - ESX Jobbank

## Installation

1. **Add to Your server.cfg**: Ensure the Dank_Utils resource is started before any other resource that depends on it.
  ensure Dank_Utils

 
2. **Configure Dependencies**: Update the `fxmanifest.lua` file by **following the instructions** provided within the file. **Uncomment** lines for frameworks or scripts you are using (remove the `--` at the beginning of the line). **Comment out** lines for frameworks or libraries you are not using (add `--` at the start of the line) or keep them commented.

Here is an example illustrating how to configure your `fxmanifest.lua`:

```lua
fx_version 'cerulean'
game 'gta5'

name 'Doii_Utils'
author 'Dankbudbaker'
description 'Dank_Utils Framework & Script Compatibility'
version '1.0.0'

-- **INSTRUCTIONS:**
-- If you DO NOT use the framework or library mentioned, add or keep `--` at the start of the line to disable it.
-- If you USE the framework, ensure there is no `--` at the beginning of the line.

client_scripts {
    '@qbx_core/modules/playerdata.lua', -- DISABLE THIS LINE IF YOU DON'T USE QBX-CORE (Keep or add --)
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

shared_scripts {
    '@ox_lib/init.lua', -- DISABLE THIS LINE IF YOU DON'T USE OX_LIB (Keep or add --)
    '@qbx_core/modules/lib.lua', -- DISABLE THIS LINE IF YOU DON'T USE QBX-CORE (Keep or add --)
    'shared/exports.lua',
}

escrow_ignore {
    'shared/**',
    'client/**',
    'server/**'
}

files {
   'config/shared.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'

```

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
