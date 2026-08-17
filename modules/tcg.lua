--[[
    Dank_Utils module: TCG helpers (Phase 2: Utility Centralization)
    Access via: Dank.tcg.CalculateDamage(...), Dank.tcg.ValidateEnergy(...)

    Reads the master card dictionary from the global `TCG.Cards` table
    (populated by the Dank_PokemonTCG resource's shared/cards.lua).
]]

local sharedConfig = require 'config.dankutils_shared'
local LogDebug = LogDebug

---@class DankTcg
local tcg = {}

---@return table|nil
local function getCards()
    if TCG and TCG.Cards then return TCG.Cards end
    if _G.TCG and _G.TCG.Cards then return _G.TCG.Cards end
    return nil
end

--- Returns the card data table for an item name (e.g. 'tcg_pikachu').
---@param cardName string
---@return table|nil
function tcg.GetCard(cardName)
    local cards = getCards()
    local card = cards and cards[cardName]

    if not cards then
        LogDebug('[tcg] GetCard: TCG.Cards dictionary not found')
    elseif not card then
        LogDebug(('[tcg] GetCard: unknown card %s'):format(tostring(cardName)))
    end

    return card
end

--- Checks whether the attached energies satisfy the required energy cost.
---@param activeCardName string  Item name of the attacking card (e.g. 'tcg_pikachu')
---@param requiredEnergy table|number  Energy cost table { grass = 1, colorless = 2 } or the attack index of the active card
---@param attachedEnergy table  Attached energy counts { grass = 2, fire = 1, ... }
---@return boolean
function tcg.ValidateEnergy(activeCardName, requiredEnergy, attachedEnergy)
    LogDebug(('[tcg] ValidateEnergy(active=%s, required=%s)'):format(tostring(activeCardName), tostring(requiredEnergy)))
    local card = tcg.GetCard(activeCardName)
    if not card then
        LogDebug(('[tcg] ValidateEnergy: active card not found (%s)'):format(tostring(activeCardName)))
        return false
    end

    if type(requiredEnergy) == 'number' then
        local attack = card.attacks and card.attacks[requiredEnergy]
        if not attack then return false end
        requiredEnergy = attack.cost
    end

    if type(requiredEnergy) ~= 'table' then return false end
    attachedEnergy = type(attachedEnergy) == 'table' and attachedEnergy or {}

    for energyType, amount in pairs(requiredEnergy) do
        if (attachedEnergy[energyType] or 0) < amount then
            return false
        end
    end

    return true
end

--- Calculates attack damage including weakness multipliers and resistance reduction.
---@param attackerName string  Item name of the attacking card
---@param defenderName string  Item name of the defending card
---@param attackIndex number    1-based index into the attacker's attacks table
---@return number Final damage (never below 0)
function tcg.CalculateDamage(attackerName, defenderName, attackIndex)
    LogDebug(('[tcg] CalculateDamage(attacker=%s, defender=%s, attack=%s)'):format(tostring(attackerName), tostring(defenderName), tostring(attackIndex)))
    local attacker = tcg.GetCard(attackerName)
    local defender = tcg.GetCard(defenderName)

    if not attacker or not defender then
        LogDebug('[tcg] CalculateDamage: attacker or defender card not found')
        return 0
    end

    local attack = attacker.attacks and attacker.attacks[attackIndex]
    if not attack or not attack.damage then return 0 end

    local damage = attack.damage

    if defender.weakness and defender.weakness.type == attacker.type then
        damage = math.floor(damage * (defender.weakness.multiplier or 2))
    end

    if defender.resistance and defender.resistance.type == attacker.type then
        damage = damage - (defender.resistance.reduction or 30)
    end

    if damage < 0 then damage = 0 end

    return damage
end

--- Convenience: total attack cost of a card's attack (sum of all energy requirements).
---@param activeCardName string
---@param attackIndex number
---@return number
function tcg.AttackCost(activeCardName, attackIndex)
    LogDebug(('[tcg] AttackCost(active=%s, attack=%s)'):format(tostring(activeCardName), tostring(attackIndex)))
    local card = tcg.GetCard(activeCardName)
    if not card or not card.attacks then return 0 end
    local attack = card.attacks[attackIndex]
    if not attack or not attack.cost then return 0 end

    local total = 0
    for _, amount in pairs(attack.cost) do
        total = total + amount
    end
    return total
end

return tcg
