-- @module Target
--- @desc A module that provides a unified interface for different target systems like qb-target and ox_target.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Target = Framework.Target or {}

if SharedConfig.Target == 'qb-target' or SharedConfig.Target == 'ox_target' then
    Framework.Status.Target = SharedConfig.Target
end

return Framework
