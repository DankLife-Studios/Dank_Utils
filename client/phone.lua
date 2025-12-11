-- @module Phone
--- @desc A module that provides a unified interface for different frameworks like qbx_core, qb-core, and es_extended.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Phone = Framework.Phone or {}

local sharedConfig = require 'config.shared'

if sharedConfig.Phone == 'npwd' or sharedConfig.Phone == 'lb-phone' or sharedConfig.Phone == 'qb-phone' then
    Framework.Status.Phone = sharedConfig.Phone
end

return Framework