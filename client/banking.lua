-- @module Banking
--- @desc A module that provides a unified interface for different frameworks like qbx_core, qb-core, and es_extended.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Banking = Framework.Banking or {}

local sharedConfig = require 'config.shared'

if sharedConfig.Banking == 'okokBanking' or sharedConfig.Banking == 'qb-banking' or sharedConfig.Banking == 'Renewed-Banking' then
    Framework.Status.Banking = sharedConfig.Banking
end

return Framework