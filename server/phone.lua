-- @module Phone
-- @desc Server-side phone operations for Dank Utils, supporting multiple phone systems.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Phone = Framework.Phone or {}

local sharedConfig = require 'config.shared'

Framework.Phone.GetEquippedPhoneNumber = function(source)
	local phoneNumber
    if sharedConfig.Phone == 'npwd' then
		phoneNumber = exports.npwd:generatePhoneNumber()
        return phoneNumber
	elseif sharedConfig.Phone == 'lb-phone' then
		phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(source)
        return phoneNumber
    else
        LogDebug('[Dank Utils] Unsupported phone system for GetEquippedPhoneNumber: ' .. tostring(sharedConfig.Phone))
        return nil
    end
end

-- Set phone status if valid and active
local validPhones = {
    ['npwd'] = true,
    ['lb-phone'] = true
}

if sharedConfig.Phone and validPhones[sharedConfig.Phone] then
    local state = GetResourceState(sharedConfig.Phone)
    if state == 'started' or state == 'starting' then
        Framework.Status.Phone = sharedConfig.Phone
    else
        LogDebug('[Dank Utils] Phone resource "' .. sharedConfig.Phone .. '" is not active.')
    end
elseif sharedConfig.Phone ~= 'AutoDetect' then
    LogDebug('[Dank Utils] Unsupported Phone option: ' .. tostring(sharedConfig.Phone))
end

return Framework