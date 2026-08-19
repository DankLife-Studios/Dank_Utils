# Permissions · Debug

Reference for the `Dank.permissions` and `Dank.debug` modules.

## Permissions

`Dank.permissions` combines explicit FiveM ACE checks with framework-specific permission and job data.

### Server API

| Function | Returns | Description |
|---|---|---|
| `Dank.permissions.hasAce(source, ace)` | `boolean` | Checks `ace`, `group.<ace>`, and `command.<ace>`. |
| `Dank.permissions.hasPermission(source, permission)` | `boolean` | Checks ACE first, then the active framework's permission/group API. |
| `Dank.permissions.getPermission(source)` | `string` | Returns the framework permission when available; otherwise `'admin'` or `'user'`. |
| `Dank.permissions.addPermission(target, permission)` | `boolean` | Adds a permission through Qbox ACE commands or QBCore. |
| `Dank.permissions.removePermission(target, permission)` | `boolean` | Removes a permission through Qbox ACE commands or QBCore. |
| `Dank.permissions.isAdmin(source)` | `boolean` | Checks common admin ACEs and framework permission groups. |
| `Dank.permissions.hasAnyJob(source, jobs)` | `boolean` | Tests the player's current job against a string, array, or keyed table. |
| `Dank.permissions.isAuthorized(source, options)` | `boolean` | Passes when any configured admin, ACE, permission, or job rule matches. |

Invalid or missing player sources fail closed. `getPermission` returns `'user'`; all boolean checks return `false`.

### ACE matching

```lua
-- Checks all three:
--   dank.reports
--   group.dank.reports
--   command.dank.reports
local allowed = Dank.permissions.hasAce(source, 'dank.reports')
```

The generic `command` ACE is not treated as permission to every command. It is only considered when explicitly checking `command` or by `isAdmin` as part of its admin policy.

### Authorization options

| Option | Type | Effect |
|---|---|---|
| `allowAdmins` | `boolean` | Allows players recognized by `isAdmin`. |
| `allowAce` | `boolean` | Also enables the same administrator bypass. |
| `ace` | `string` or `string[]` | Checks one or more explicit ACE permissions. |
| `permissions` | `string` or `string[]` | Checks one or more framework-aware permissions. |
| `jobs` | `string` or `table` | Checks one or more job names. |

Rules use OR behavior: the player is authorized as soon as one configured rule matches.

```lua
local allowed = Dank.permissions.isAuthorized(source, {
    allowAdmins = true,
    ace = { 'dank.reports', 'dank.manage' },
    permissions = 'moderator',
    jobs = { police = true, ambulance = true }
})

if not allowed then
    return
end
```

`jobs` also accepts a single name or an array:

```lua
Dank.permissions.hasAnyJob(source, 'police')
Dank.permissions.hasAnyJob(source, { 'police', 'ambulance' })
Dank.permissions.hasAnyJob(source, { police = true, ambulance = true })
```

### Changing permissions

```lua
local added = Dank.permissions.addPermission(source, 'admin')

if added then
    Dank.permissions.removePermission(source, 'admin')
end
```

On Qbox, a numeric target becomes `player.<source>`. A string target is used as the full principal, for example `identifier.license:...`. Unsupported frameworks and invalid target types return `false`.

### Client API

| Function | Returns | Description |
|---|---|---|
| `Dank.permissions.hasAnyJob(jobs)` | `boolean` | Checks the local player's current job. |
| `Dank.permissions.isAuthorized(options)` | `boolean` | Enforces `options.jobs` locally. If no jobs rule is supplied, returns `true`. |

```lua
if Dank.permissions.hasAnyJob({ 'police', 'ambulance' }) then
    print('Emergency services access')
end
```

Client authorization is intentionally job-only. Keep ACE, group, admin, and other security-sensitive authorization on the server.

### Supported permission backends

- FiveM ACE on every framework
- Qbox (`qbx_core`)
- QBCore (`qb-core`)
- ESX (`es_extended`)
- ND Core (`ND_Core`)
- Ox Core (`ox_core`)

## Debug

`Dank.debug` provides shared, level-aware console output controlled by one server-side switch.

### API

| Member | Scope | Returns | Description |
|---|:---:|---|---|
| `Dank.debug.enable` | Server write, shared read | `boolean` | Master state. Defaults to `false`. |
| `Dank.debug.get()` | Shared | `boolean` | Returns the active server or replicated client state. |
| `Dank.debug.print(message, level?)` | Shared | — | Prints only while debugging is enabled. |

Set the switch in a server script. The value is replicated through the `dankutils:debug` global state bag so clients read the same state. Client writes are ignored.

```lua
-- server.lua
Dank.debug.enable = true

Dank.debug.print('Player loaded')
Dank.debug.print('No data found', 'warning')
Dank.debug.print('Database request failed', 'error')

-- Repeated changes are replicated correctly.
Dank.debug.enable = false
Dank.debug.enable = true
```

```lua
-- client.lua
if Dank.debug.get() then
    Dank.debug.print('Debug is enabled by the server', 'info')
end

-- Ignored: clients cannot change the shared state.
Dank.debug.enable = false
```

### Levels

| Value | Output tag | Console color |
|---|---|---|
| `nil`, `'info'`, or an unknown value | `INFO` | Purple |
| `'warning'` or `'warn'` | `WARNING` | Yellow |
| `'error'` | `ERROR` | Red |

Messages are prefixed with the resource returned by `GetCurrentResourceName()`:

```text
[my_resource] [INFO] Player loaded
[my_resource] [WARNING] No data found
[my_resource] [ERROR] Database request failed
```

---

[Back to documentation index](../README.md)