# 🛡️ Permissions · 🐛 Debug

## Dank.permissions

> Unified permission checks across FiveM ACE, QB-Core, ESX, ND_Core, and ox_core.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Server]` | `Dank.permissions.hasAce(source, ace)` | Checks an explicit FiveM ACE permission (also tries `group.*` and `command.*` variants). |
| `[Server]` | `Dank.permissions.hasPermission(source, perm)` | ACE first, then the framework-specific fallback. |
| `[Server]` | `Dank.permissions.getPermission(source)` | Returns the player's permission level (`'admin'` / `'user'`). |
| `[Server]` | `Dank.permissions.addPermission(target, perm)` | Adds a permission to a player ID or principal string. |
| `[Server]` | `Dank.permissions.removePermission(target, perm)` | Removes a permission from a player ID or principal string. |
| `[Server]` | `Dank.permissions.isAdmin(source)` | Checks admin status via ACE plus framework groups. |
| `[Server]` | `Dank.permissions.hasAnyJob(source, jobs)` | Checks whether a player has any of the given jobs (string or table). |
| `[Server]` | `Dank.permissions.isAuthorized(source, options)` | Comprehensive check: `{ allowAdmins, allowAce, ace, permissions, jobs }`. |
| `[Client]` | `Dank.permissions.hasAnyJob(jobs)` | Checks the local player's job (string or table). |
| `[Client]` | `Dank.permissions.isAuthorized(options)` | Local job-based authorization check. |

### Usage

```lua
-- Server
if Dank.permissions.isAdmin(source) then
    print('An admin!')
end

if Dank.permissions.hasAnyJob(source, { 'police', 'ambulance' }) then
    print('Emergency services')
end

local allowed = Dank.permissions.isAuthorized(source, {
    allowAdmins = true,
    ace         = 'dank.admin',
    jobs        = 'police',
})

Dank.permissions.addPermission(source, 'admin')
```

```lua
-- Client
if Dank.permissions.hasAnyJob({ 'police', 'ambulance' }) then
    print('I am emergency services')
end
```

### Supported Frameworks

FiveM ACE (all frameworks) · QB-Core · QBX-Core · ESX · ND_Core · ox_core

---

## Dank.debug

> Per-script debug logging with script names, levels, and console colors — on both client and server.

### Properties

| Property | Type | Description |
|---|---|---|
| `Dank.debug.enable` | `boolean` | **Server-side only** master switch. `true` prints, `false` silences. Defaults to `false`. Client-side writes are ignored. |

> ⚡ **Server-side only**
>
> `Dank.debug.enable` can only be set from the **server**. The server replicates the flag to all clients through the `dankutils:debug` state bag, enabling **both server and client** debug prints with one line. Clients can read the flag (and use `Dank.debug.get()`), but cannot change it.

### Functions

| Scope | Function | Description |
|:---:|---|---|
| `[Shared]` | `Dank.debug.get()` | Returns whether debug is enabled for the calling script (`true` / `false`). |
| `[Shared]` | `Dank.debug.print(message, level?)` | Prints a debug message prefixed with the calling script's name. Level: `'info'` (default), `'warning'`, or `'error'`. |

> 💡 Each script controls its own switch — enabling it in one resource does not affect any other resource.

### Usage

```lua
-- ✅ SERVER file (sv_*.lua) — enables prints on BOTH server and client
Dank.debug.enable = true

-- Server or client usage
if Dank.debug.get() then
    print('Debug is on')
end

Dank.debug.print('Player loaded', 'info')
Dank.debug.print('No data found', 'warning')
Dank.debug.print('Critical failure', 'error')

Dank.debug.enable = false -- silence both sides again
```

```lua
-- ❌ CLIENT file (cl_*.lua) — IGNORED, Dank.debug.enable is server-side only
Dank.debug.enable = true -- no effect

-- ✅ Clients can still READ the state
if Dank.debug.get() then
    print('Debug is enabled by the server')
end
```

Console output:

```
[Dank_LicenseCenter] [INFO] Player loaded
[Dank_LicenseCenter] [WARNING] No data found
[Dank_LicenseCenter] [ERROR] Critical failure
```

| Level | Console color |
|:---:|:---:|
| `info` | Blue |
| `warning` | Yellow |
| `error` | Red |

---

[← Back to README](../README.md)
