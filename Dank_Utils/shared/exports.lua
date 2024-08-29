--- This section simply exports the Framework table for use in other resources.
-- @script shared/exports.lua

--- Exports a function to get a deep copy of the Framework object.
-- This exported function allows other scripts to safely access and manipulate their own copy of the Framework object without affecting the original global state.
-- This is particularly useful in multi-threaded or complex applications where maintaining isolated state is crucial.
-- @function get_object
-- @usage local Framework = exports['Dank_Utils'].Framework()
-- @return table: A deep copy of the Framework object, ensuring isolated state and no side effects on the original Framework object.
exports('Framework', function()
    return Framework.tables.deep_copy(Framework)
end)