# 🏦 Banking · 🧠 Core · 📱 Phone

## Dank.banking

> Society and standard account operations across major banking resources.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Server]` | `Dank.banking.getAccountBalance(account)` | Returns the balance for a society or standard account. |
| `[Server]` | `Dank.banking.addMoney(account, amount)` | Deposits money into an account. |
| `[Server]` | `Dank.banking.removeMoney(account, amount)` | Withdraws money from an account. |

> 📌 If `account` is a numeric player source, operations fall back to the framework bank account (`Dank.player` money functions).

### Usage

```lua
-- Server
Dank.banking.addMoney('society_police', 500)
local balance = Dank.banking.getAccountBalance('society_police')

if balance >= 500 then
    Dank.banking.removeMoney('society_police', 500)
end
```

### Supported Banking Systems

okokBanking · qb-banking · qb-management · fd_banking · pefcl · Renewed-Banking · esx_jobbank · qs-banking

---

## Dank.core

> Raw framework access, job lookups, command registration, and the built-in version checker.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Shared]` | `Dank.core.getFunctions()` | Exposes raw framework functions for direct overrides. |
| `[Server]` | `Dank.core.getJob(jobname)` | Fetches the configuration for a specific job. |
| `[Server]` | `Dank.core.getAllJobs()` | Fetches all registered jobs. |
| `[Server]` | `Dank.core.addCommand(name, description, args, restricted, callback, group?)` | Registers a framework-agnostic command. |
| `[Server]` | `Dank.core.versionCheck(options)` | Initializes the version checking loop. |
| `[Client]` | `Dank.onPlayerLoaded(callback)` | Registers a framework-agnostic callback for when the local player has loaded. |

> 📌 **Client event** — You can also listen directly to `Dank:Client:OnPlayerLoaded`, but using `Dank.onPlayerLoaded` is highly recommended as it natively hooks the active framework.

### Usage

```lua
-- Server
local job = Dank.core.getJob('police')

Dank.core.addCommand('heal', 'Heals the player', {}, false, function(source, args)
    print(('Player %s healed'):format(source))
end)
```

```lua
-- Client
Dank.onPlayerLoaded(function()
    print('Player data is ready!')
end)
```

### Version Checking

```lua
-- Server
Dank.core.versionCheck({
    originalScriptName = 'Dank_Bahama_Mama',  -- script name expected in the remote JSON
    updateURL          = 'https://.../versions.json',
    checkInterval      = 60 * 60 * 1000,      -- 1 hour
})
```

### Supported Frameworks

QB-Core · QBX-Core · ESX · ND_Core · ox_core

---

## Dank.phone

> Send emails and SMS through the active phone system.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Server]` | `Dank.phone.sendEmail(source, data)` | Sends an email. `data`: `{ sender, subject, message, button? }`. |
| `[Server]` | `Dank.phone.sendSMS(source, data)` | Sends an SMS. `data`: `{ number, message }`. |

### Usage

```lua
-- Server
Dank.phone.sendEmail(source, {
    sender  = 'City Hall',
    subject = 'Your license',
    message = 'Your license application has been approved.',
    button  = {
        buttonEvent = 'cityhall:openLicense',
        buttonData  = { type = 'pilot' },
    },
})

Dank.phone.sendSMS(source, {
    number  = '555-0100',
    message = 'You have an appointment at City Hall.',
})
```

### Supported Phone Systems

lb-phone · qs-smartphone · qb-phone · gksphone · yseries (yphone) · npwd

---

[← Back to README](../README.md)
