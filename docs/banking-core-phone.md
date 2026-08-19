# Banking · Core · Phone

Reference for the `Dank.banking`, `Dank.core`, and `Dank.phone` modules.

## Banking

`Dank.banking` provides account balance and money mutation helpers across supported banking resources.

### Server API

| Function | Returns | Description |
|---|---|---|
| `Dank.banking.getAccountBalance(account)` | `number` | Returns the account balance. Unsupported adapters and missing accounts return `0`. |
| `Dank.banking.addMoney(account, amount)` | adapter result or `false` | Adds a positive amount to an account. |
| `Dank.banking.removeMoney(account, amount)` | adapter result or `false` | Removes a positive amount from an account. |

`account` is usually an account name or identifier. When no supported banking resource is running, numeric account values are treated as player sources and use framework bank money as a fallback.

Mutation helpers reject missing, zero, and negative amounts and return `false` without calling the configured resource.

```lua
local account = 'business_police'

local balance = Dank.banking.getAccountBalance(account)
print(('Current balance: $%s'):format(balance))

if not Dank.banking.addMoney(account, 500) then
    print('Unable to credit the account')
end

if balance >= 250 and not Dank.banking.removeMoney(account, 250) then
    print('Unable to debit the account')
end
```

### Supported banking systems

| Resource | Balance | Add | Remove |
|---|:---:|:---:|:---:|
| `Renewed-Banking` | ✓ | ✓ | ✓ |
| `okokBanking` | ✓ | ✓ | ✓ |
| `qb-banking` | ✓ | ✓ | ✓ |
| `qb-management` | ✓ | ✓ | ✓ |
| `fd_banking` | ✓ | ✓ | ✓ |
| `pefcl` | ✓ | ✓ | ✓ |
| `esx_jobbank` | ✓ | ✓ | ✓ |
| `qs-banking` | ✓ | ✓ | ✓ |

## Core

`Dank.core` exposes framework access, job data, command registration, version checks, and player-load lifecycle hooks.

### Shared API

| Function | Returns | Description |
|---|---|---|
| `Dank.core.getFunctions()` | `table` or `nil` | Returns the detected framework functions/object or raw exports. The exact shape is adapter-specific. |

### Server API

| Function | Returns | Description |
|---|---|---|
| `Dank.core.getJob(jobName)` | `table` or `nil` | Returns one job definition. |
| `Dank.core.getAllJobs()` | `table` | Returns every available job definition. |
| `Dank.core.addCommand(name, description, args, restricted, callback, group?)` | — | Registers a framework command. |
| `Dank.core.versionCheck(options?)` | — | Starts a recurring JSON-backed version check for the current resource. |
| `Dank.core.onPlayerLoaded(callback)` | — | Runs `callback(source, ...)` whenever a player-loaded event fires. |

### Client API

| Function | Returns | Description |
|---|---|---|
| `Dank.core.onPlayerLoaded(callback)` | — | Runs `callback(...)` whenever the local player-loaded event fires. |

The callback helper normalizes the detected framework event. Register it during resource startup so no load event is missed.

```lua
-- server.lua
Dank.core.onPlayerLoaded(function(source)
    print(('Player %s is ready'):format(source))
end)
```

```lua
-- client.lua
Dank.core.onPlayerLoaded(function()
    print('Local player is ready')
end)
```

### Commands

```lua
Dank.core.addCommand(
    'coords',
    'Print your current coordinates',
    {},
    false,
    function(source)
        print(source, GetEntityCoords(GetPlayerPed(source)))
    end,
    'admin'
)
```

Command callback arguments and permission formats follow the active framework. When a framework command API is unavailable, the module falls back to `RegisterCommand`.

### Version checks

```lua
Dank.core.versionCheck({
    originalScriptName = 'my_resource',
    updateURL = 'https://example.com/scripts_version.json',
    checkInterval = 60 * 60 * 1000
})
```

| Option | Description |
|---|---|
| `originalScriptName` | Key to read from the remote JSON object. Defaults to the current resource name. |
| `updateURL` | URL of a JSON object whose keys are script names and values are versions. |
| `checkInterval` | Delay between checks in milliseconds. Defaults to one hour and is clamped to at least one second. |

Passing a string is shorthand for `originalScriptName`. The local version comes from the current resource's `version` or `script_version` manifest metadata. Malformed versions, invalid JSON, missing keys, and failed HTTP responses are reported without raising an unhandled error. Repeated identical status messages are suppressed.

### Supported frameworks

- Qbox (`qbx_core`)
- QBCore (`qb-core`)
- ESX (`es_extended`)
- Ox Core (`ox_core`)
- ND Core (`ND_Core`)

## Phone

`Dank.phone` sends emails and SMS-style messages through the detected phone resource.

### Server API

| Function | Returns | Description |
|---|---|---|
| `Dank.phone.sendEmail(source, data)` | `boolean` or adapter result | Sends an email. Invalid input and unsupported adapters return `false`. |
| `Dank.phone.sendSMS(source, data)` | `boolean` or adapter result | Sends an SMS-style message. Invalid input and unsupported adapters return `false`. |

### Email data

| Field | Type | Required | Description |
|---|---|:---:|---|
| `to` | `string` | LB alternative | Explicit destination email address for LB Phone. |
| `sender` | `string` | No | Sender name or address. Defaults to `'System'`. |
| `subject` | `string` | No | Email subject. Defaults to `'Notification'`. |
| `message` | `string` | No | Email body. Defaults to an empty string. |
| `button` | `table` | No | Legacy phone button/action data. |
| `attachments` | `table` | No | LB Phone attachments. |
| `actions` | `table` | No | LB Phone action definitions. |

The `source` function argument is required. For LB Phone, `data.to` takes priority. If it is omitted, the module resolves the source player's equipped phone number and then its email address. If no destination can be resolved, the function returns `false`.

```lua
local sent = Dank.phone.sendEmail(source, {
    sender = 'City Services',
    subject = 'Application update',
    message = 'Your application has been approved.',
    button = {
        enabled = true,
        buttonEvent = 'city:client:openApplication',
        buttonData = { applicationId = 42 }
    }
})

if not sent then
    print('Email could not be sent')
end
```

LB Phone can also be addressed directly:

```lua
Dank.phone.sendEmail(source, {
    to = 'citizen@lb-phone.com',
    sender = 'City Services',
    subject = 'Receipt',
    message = 'Your payment was received.',
    attachments = {
        { type = 'image', source = 'https://example.com/receipt.png' }
    }
})
```

### SMS data

| Field | Type | Required | Description |
|---|---|:---:|---|
| `number` | `string` | Adapter-specific | Destination number used by LB Phone, GKS Phone, YSeries, and NPWD. |
| `message` | `string` | No | Message body. Empty/nil handling is adapter-specific. |
| `from` | `string` | No | Sender number/name. Preferred for LB Phone. |
| `sender` | `string` | No | Compatible sender alias. |
| `attachments` | `table` | No | LB Phone attachments. |

```lua
local sent = Dank.phone.sendSMS(source, {
    number = '5550123',
    from = 'City Services',
    message = 'Your vehicle is ready for collection.'
})

if not sent then
    print('SMS could not be sent')
end
```

Some legacy adapters surface SMS through their notification/event API rather than storing a conversation thread.

### Supported phone systems

- `lb-phone`
- `qs-smartphone`
- `qs-smartphone-pro`
- `qb-phone`
- `gksphone`
- `yseries`
- `yphone`
- `npwd`

---

[Back to documentation index](../README.md)