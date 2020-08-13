---Static class for the scripting game logic of my entities.
Entity = {}

--[[
    Data this class stores in global
    --------------------------------
    nothing
]]
-- local all the frequently called functions for supercalifragilisticexpialidocious performance gains
local global
local caste_bonuses
local water_values = DrinkingWater.values

local floor = math.floor
local min = math.min
local random = math.random

local set_beacon_effects = Subentities.set_beacon_effects

local get_building_details = Buildings.get

local has_power = Subentities.has_power

local function set_locals()
    global = _ENV.global
    caste_bonuses = global.caste_bonuses
end

function Entity.init()
    set_locals()
end

function Entity.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << general helper functions >>
local function get_speed_from_performance(performance)
    return floor(100 * performance - 20)
end

local function set_assembling_machine_performance(entry, performance)
    entry[EK.performance] = performance

    local entity = entry[EK.entity]

    local is_active = performance >= 0.2
    entity.active = is_active

    if is_active then
        set_beacon_effects(entry, get_speed_from_performance(performance), 0, true)
    end
end

---------------------------------------------------------------------------------------------------
-- << beaconed machines >>

-- TODO guis for these guys
local function update_machine(entry)
    set_beacon_effects(entry, caste_bonuses[Type.clockwork], 0, global.use_penalty)
end
Register.set_entity_updater(Type.assembling_machine, update_machine)
Register.set_entity_updater(Type.furnace, update_machine)
Register.set_entity_updater(Type.mining_drill, update_machine)

local function update_farm(entry)
    set_beacon_effects(entry, caste_bonuses[Type.clockwork], caste_bonuses[Type.ember], global.use_penalty)
end
Register.set_entity_updater(Type.farm, update_farm)

local function update_orangery(entry)
    local age = game.tick - entry[EK.tick_of_creation]
    -- TODO balance the age productivity gain
    set_beacon_effects(entry, caste_bonuses[Type.clockwork], caste_bonuses[Type.ember] + math.sqrt(age), global.use_penalty)
end
Register.set_entity_updater(Type.orangery, update_orangery)

local function update_silo(entry)
    set_beacon_effects(entry, caste_bonuses[Type.clockwork], caste_bonuses[Type.aurora], global.use_penalty)
end
Register.set_entity_updater(Type.rocket_silo, update_silo)

---------------------------------------------------------------------------------------------------
-- << immigration port >>
local function schedule_immigration_wave(entry, building_details)
    entry[EK.next_wave] =
        (entry[EK.next_wave] or game.tick) + building_details.interval + random(building_details.random_interval) - 1
end

local function create_immigration_port(entry)
    schedule_immigration_wave(entry, get_building_details(entry))
end
Register.set_entity_creation_handler(Type.immigration_port, create_immigration_port)

local function update_immigration_port(entry, _, current_tick)
    local tick_next_wave = entry[EK.next_wave]
    if current_tick >= tick_next_wave then
        local building_details = get_building_details(entry)
        if Inventories.try_remove_item_range(entry, building_details.materials) then
            Inhabitants.migration_wave(building_details)
        end

        schedule_immigration_wave(entry, building_details)
    end
end
Register.set_entity_updater(Type.immigration_port, update_immigration_port)

---------------------------------------------------------------------------------------------------
-- << manufactory >>
local function update_manufactory(entry)
    Inhabitants.update_workforce(entry)
    local performance = Inhabitants.evaluate_workforce(entry)
    set_assembling_machine_performance(entry, performance)
end
Register.set_entity_updater(Type.manufactory, update_manufactory)

---------------------------------------------------------------------------------------------------
-- << nightclub >>
local function update_nightclub(entry)
    if not has_power(entry) then
        entry[EK.performance] = 0
        return
    end

    local worker_performance = Inhabitants.evaluate_workforce(entry)

    -- TODO consume and evaluate drinks

    entry[EK.performance] = worker_performance
end
Register.set_entity_updater(Type.nightclub, update_nightclub)

local function create_nightclub(entry)
    entry[EK.performance] = 0
end
Register.set_entity_creation_handler(Type.nightclub, create_nightclub)

---------------------------------------------------------------------------------------------------
-- << fishery >>
local function get_water_tiles(entry, surface, area)
    if global.last_tile_update > (entry[EK.last_tile_update] or -1) then
        local water_tiles = surface.count_tiles_filtered {area = area, collision_mask = "water-tile"}

        entry[EK.water_tiles] = water_tiles
        entry[EK.last_tile_update] = game.tick
        return water_tiles
    else
        -- nothing could possibly have changed, return the cached value
        return entry[EK.water_tiles]
    end
end

local function get_fishery_performance(entry, entity)
    local building_details = get_building_details(entry)

    local worker_performance = Inhabitants.evaluate_workforce(entry)

    local surface = entity.surface
    local position = entity.position
    local water_tiles =
        get_water_tiles(entry, surface, Tirislib_Utils.get_range_bounding_box(position, building_details.range))
    local water_performance = min(water_tiles / building_details.water_tiles, 1)

    local neighborhood_performance = 1 / (Neighborhood.get_neighbor_count(entry, Type.fishery) + 1)

    return min(worker_performance, water_performance) * neighborhood_performance
end

local function update_fishery(entry)
    Inhabitants.update_workforce(entry)
    local entity = entry[EK.entity]
    local performance = get_fishery_performance(entry, entity)
    set_assembling_machine_performance(entry, performance)
end
Register.set_entity_updater(Type.fishery, update_fishery)

local function create_fishery(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.fishery, create_fishery)

---------------------------------------------------------------------------------------------------
-- << water distributer >>
local function update_water_distributer(entry)
    local entity = entry[EK.entity]

    -- determine and save the type of water that this distributer provides
    -- this is because it's unlikely to ever change (due to the system that prevents fluids from mixing)
    -- but needs to be checked often
    if has_power(entry) then
        for fluid_name in pairs(entity.get_fluid_contents()) do
            local water_value = water_values[fluid_name]
            if water_value then
                entry[EK.water_quality] = water_value.health
                entry[EK.water_name] = fluid_name
                return
            end
        end
    end
    entry[EK.water_quality] = 0
    entry[EK.water_name] = nil
end
Register.set_entity_updater(Type.water_distributer, update_water_distributer)

---------------------------------------------------------------------------------------------------
-- << waterwell >>
local function update_waterwell(entry)
    -- +1 so it counts itself too
    local near_count = Neighborhood.get_neighbor_count(entry, Type.waterwell) + 1
    local performance = near_count ^ (-0.65)
    set_assembling_machine_performance(entry, performance)
end
Register.set_entity_updater(Type.waterwell, update_waterwell)

local function create_waterwell(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.waterwell, create_waterwell)
