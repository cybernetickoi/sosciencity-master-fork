Subentities = {}

Subentities.subentity_name_lookup = {
    [SUB_BEACON] = "sosciencity-hidden-beacon",
    [SUB_EEI] = "sosciencity-hidden-eei"
}

---------------------------------------------------------------------------------------------------
-- << general >>
local function add(entry, _type)
    local subentity =
        entry.entity.surface.create_entity {
        name = Subentities.subentity_name_lookup[_type],
        position = entry.entity.position,
        force = entry.entity.force
    }

    entry.subentities[_type] = subentity

    return subentity
end

local function add_sprite(entry, name, alt_mode)
    local sprite_id = rendering.draw_sprite {
        sprite = name,
        target = entry.entity,
        surface = entry.entity.surface,
        only_in_alt_mode = (alt_mode or false)
    }

    entry.sprite = sprite_id

    return sprite_id
end

function Subentities.add_all_for(entry)
    if Types:needs_beacon(entry.type) then
        add(entry, SUB_BEACON)
    end
    if Types:needs_eei(entry.type) then
        add(entry, SUB_EEI)
    end
    if Types:needs_alt_mode_sprite(entry.type) then
        add_sprite(entry, Types.caste_sprites[entry.type], true)
    end
end

function Subentities.remove_all_for(entry)
    for _, subentity in pairs(entry.subentities) do
        if subentity.valid then
            subentity.destroy()
        end
    end
    -- we don't need to destroy sprites when their target entity gets destroyed
end

function Subentities.get(entry, _type)
    -- there is the possibility that the subentity gets lost
    -- in this case we simply create a new one
    if entry.subentities[_type] and entry.subentities[_type].valid then
        return entry.subentities[_type]
    else
        return add(entry, _type)
    end
end

---------------------------------------------------------------------------------------------------
-- << hidden beacons >>
local SPEED_MODULE_NAME = "-sosciencity-speed"
local PRODUCTIVITY_MODULE_NAME = "-sosciencity-productivity"
local PENALTY_MODULE_NAME = "sosciencity-penalty"

local MAX_MODULE_STRENGTH = 14

-- assumes that value is an integer
local function set_binary_modules(beacon_inventory, module_name, value)
    local new_value = value
    local strength = 0

    while value > 0 and strength <= MAX_MODULE_STRENGTH do
        new_value = math.floor(value / 2)

        if new_value * 2 ~= value then
            beacon_inventory.insert {
                name = strength .. module_name,
                count = 1
            }
        end

        strength = strength + 1
        value = new_value
    end
end

-- speed and productivity need to be positive
function Subentities.set_beacon_effects(entry, speed, productivity, add_penalty)
    local beacon = Subentities.get(entry, SUB_BEACON)

    local beacon_inventory = beacon.get_module_inventory()
    beacon_inventory.clear()

    if speed and speed > 0 then
        set_binary_modules(beacon_inventory, SPEED_MODULE_NAME, speed)
    end
    if productivity and productivity > 0 then
        set_binary_modules(beacon_inventory, PRODUCTIVITY_MODULE_NAME, productivity)
    end

    if add_penalty then
        beacon_inventory.insert {name = PENALTY_MODULE_NAME}
    end
end

---------------------------------------------------------------------------------------------------
-- << hidden electric energy interface >>

-- Checks if the entity is supplied with power. Assumes that the entry has an eei.
function Subentities.has_power(entry)
    -- check if the buffer is partially filled
    return Subentities.get(entry, SUB_EEI).power > 0
end

-- Gets the current power usage of a housing entity
local function get_residential_power_consumption(entry)
    local usage_per_inhabitant = Caste(entry).power_demand
    return -1 * entry.inhabitants * usage_per_inhabitant
end

-- Sets the power usage of the entity. Assumes that the entry has an eei.
-- usage seems to be in W
function Subentities.set_power_usage(entry, usage)
    usage = usage or get_residential_power_consumption(entry)
    Subentities.get(entry, SUB_EEI).power_usage = usage
end

return Subentities
