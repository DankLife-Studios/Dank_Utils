-- @module Banking
--- @desc A module that provides a unified interface for different frameworks like qbx_core, qb-core, and es_extended.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Banking = Framework.Banking or {}

if SharedConfig.Banking == 'okokBanking' or SharedConfig.Banking == 'qb-banking' or SharedConfig.Banking == 'Renewed-Banking' then
    Framework.Status.Banking = SharedConfig.Banking
end

return Framework