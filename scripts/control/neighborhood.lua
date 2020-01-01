Neighborhood = {}

---------------------------------------------------------------------------------------------------
-- << constants >>
--- Table with (neighborhood entity, range) pairs
Neighborhood.active_neighbors = {
    ["bsp"] = 42 -- range in tiles
}
local active_neighbor_ranges = Neighborhood.active_neighbors

--- Table with (entity type, neighborhood specification) pairs
Neighborhood.entity_types_aware_of_neighborhood = {
    [TYPE_CLOCKWORK] = {active_types = {TYPE_HOSPITAL, TYPE_MARKET}}
}
local entity_types_aware_of_neighborhood = Neighborhood.entity_types_aware_of_neighborhood

-- generate (neighbor, interested entity types) lookup table
local function generate_interested_entity_types_lookup()
    local interested_entity_types = {}
    for entity_type, interests in pairs(entity_types_aware_of_neighborhood) do
        for _, neighbor_type in pairs(interests) do
            if not interested_entity_types[neighbor_type] then
                interested_entity_types[neighbor_type] = {}
            end
            table.insert(interested_entity_types[neighbor_type], entity_type)
        end
    end
end
local interested_entity_types = generate_interested_entity_types_lookup()

---------------------------------------------------------------------------------------------------
-- << general >>
-- Some entities need to know if there are neighborhood entities (like hospitals) nearby.
-- This class ensures that the neighborhood aware entries have a neighborhood-table with all the neighbors that it is interested in
-- When accessing a neighbor entry it is necessary to check if it's still valid
-- neighborhood: table
--   [entity type]: table of (unit_number, entity) pairs
--
-- Future: implement something for entities that are not registered, e.g. trees

local abs = math.abs
local function maximum_metric_distance(v1, v2)
    local dist_x = abs(v1.x - v2.x)
    local dist_y = abs(v1.y - v2.y)

    -- math.max seems to be very slow
    if dist_x > dist_y then
        return dist_x
    else
        return dist_y
    end
end

local function is_in_range(neighborhood_entry, entry)
    local range = active_neighbor_ranges[neighborhood_entry[ENTITY].name]
    local position1 = neighborhood_entry[ENTITY].position
    local position2 = entry[ENTITY].position
    return maximum_metric_distance(position1, position2) <= range
end

--- Finds and adds all the neighbor entries the given entity is interested in.
--- @param entry Entry
--- @param _type Type
function Neighborhood.add_neighborhood(entry, _type)
    local details = entity_types_aware_of_neighborhood[_type]
    if not details then
        return
    end

    entry[NEIGHBORHOOD] = {}

    for _, neighborhood_type in pairs(details.active_types) do
        entry[NEIGHBORHOOD][neighborhood_type] = {}

        for unit_number, neighbor_entry in Register.all_of_type(neighborhood_type) do
            if is_in_range(neighbor_entry, entry) then
                entry[NEIGHBORHOOD][neighborhood_type][unit_number] = unit_number
            end
        end
    end
end

--- Adds the given neighbor to every interested entity in range.
--- @param neighbor_entry Entry
--- @param _type Type
function Neighborhood.establish_new_neighbor(neighbor_entry, _type)
    if not active_neighbor_ranges[neighbor_entry[ENTITY].name] then
        return
    end

    local unit_number = neighbor_entry[ENTITY].unit_number

    for _, interested_type in pairs(interested_entity_types[_type]) do
        for _, current_entry in Register.all_of_type(interested_type) do
            if is_in_range(neighbor_entry, current_entry) then
                if not current_entry[NEIGHBORHOOD][_type] then
                    current_entry[NEIGHBORHOOD][_type] = {}
                end
                current_entry[NEIGHBORHOOD][_type][unit_number] = unit_number
            end
        end
    end
end

--- Returns a complete list of all neighbors of the given type.
--- @param entry Entry
--- @param _type Type
function Neighborhood.get_by_type(entry, _type)
    if not entry[NEIGHBORHOOD] or not entry[NEIGHBORHOOD][_type] then
        return {}
    end

    local ret = {}
    local i = 1

    for unit_number, _ in pairs(entry[NEIGHBORHOOD][_type]) do
        local current_entry = Register.try_get(unit_number)
        if current_entry then
            ret[i] = current_entry
            i = i + 1
        else
            entry[NEIGHBORHOOD][_type][unit_number] = nil
        end
    end

    return ret
end

local function nothing()
end
--- Lazy iterator over all neighbors of the given type.
--- @param entry Entry
--- @param _type Type
function Neighborhood.all_of_type(entry, _type)
    if not entry[NEIGHBORHOOD] or not entry[NEIGHBORHOOD][_type] then
        return nothing
    end

    local index, current_entry
    local table_to_iterate = entry[NEIGHBORHOOD][_type]

    local function _next()
        index, _ = next(table_to_iterate, index)

        if index then
            current_entry = Register.try_get(index)

            if not current_entry then
                table_to_iterate[index] = nil
                -- skip this invalid entry
                return _next()
            end

            return index, current_entry
        end
    end

    return _next, index, current_entry
end

return Neighborhood
