-- entities
TYPE_CLOCKWORK = 1
TYPE_EMBER = 2
TYPE_GUNFIRE = 3
TYPE_GLEAM = 4
TYPE_FOUNDRY = 5
TYPE_ORCHID = 6
TYPE_AURORA = 7
TYPE_PLASMA = 8

TYPE_MARKET = 101
TYPE_WATER_DISTRIBUTION_FACILITY = 102
TYPE_HOSPITAL = 103

TYPE_CLUB = 201
TYPE_SCHOOL = 202
TYPE_BARRACK = 203
TYPE_UNIVERSITY = 204
TYPE_UNIVERSITY_MK02 = 205
TYPE_CITY_HALL = 206
TYPE_RESEARCH_CENTER = 207

TYPE_ASSEMBLY_MACHINE = 1001
TYPE_FURNACE = 1002
TYPE_ROCKET_SILO = 1003

TYPE_MINING_DRILL = 2001
TYPE_LAB = 2002
TYPE_TURRET = 2003

TYPE_NULL = 9999

-- subentities
SUB_BEACON = 1
SUB_EEI = 2

-- neighborhood
NEIGHBOR_MARKET = 1

--tastes
TASTE_BITTER = 1
TASTE_NEUTRAL = 2
TASTE_SALTY = 3
TASTE_SOUR = 4
TASTE_SPICY = 5
TASTE_SWEET = 6
TASTE_UMAMI = 7

Types = {}
Types.entity_type_lookup = {
    types = {
        ["assembly-machine"] = TYPE_ASSEMBLY_MACHINE,
        ["mining-drill"] = TYPE_MINING_DRILL,
        ["lab"] = TYPE_LAB,
        ["rocket-silo"] = TYPE_ROCKET_SILO,
        ["furnace"] = TYPE_FURNACE,
        ["ammo-turret"] = TYPE_TURRET,
        ["electric-turret"] = TYPE_TURRET,
        ["fluid-turret"] = TYPE_TURRET,
        ["turret"] = TYPE_TURRET
    },
    names = { -- TODO add the names from housing
        ["market"] = TYPE_MARKET,
        ["water-distribution-facility"] = TYPE_WATER_DISTRIBUTION_FACILITY,
        ["hospital"] = TYPE_HOSPITAL,
        ["club"] = TYPE_CLUB,
        ["school"] = TYPE_SCHOOL,
        ["barrack"] = TYPE_BARRACK,
        ["university"] = TYPE_UNIVERSITY,
        ["university-mk02"] = TYPE_UNIVERSITY_MK02,
        ["city-hall"] = TYPE_CITY_HALL,
        ["research-center"] = TYPE_CITY_HALL
    },
    __call = function(self, entity)
        return self.types[entity.type] or self.names[entity.name] or TYPE_NULL
    end
}

function Types:get_entity_type(entity)
    return Types(entity)
end

Types.caste_names = {
    [TYPE_CLOCKWORK] = "clockwork",
    [TYPE_EMBER] = "ember",
    [TYPE_GUNFIRE] = "gunfire",
    [TYPE_GLEAM] = "gleam",
    [TYPE_FOUNDRY] = "foundry",
    [TYPE_ORCHID] = "orchid",
    [TYPE_AURORA] = "aurora",
    __call = function(self, type)
        return self[type]
    end
}

function Types:get_caste_name(type)
    return self.caste_names[type]
end

function Types:is_housing(type)
    return type < 100
end

function Types:entity_is_housing(entity)
    return self.entity_type_lookup(entity) < 100
end

function Types:is_civil(type)
    return type < 1000
end

function Types:entity_is_civil(entity)
    return self.entity_type_lookup(entity) < 1000
end

function Types:is_relevant_to_register(type)
    return type < 2000
end

function Types:entity_is_relevant_to_register(entity)
    return self.entity_type_lookup(entity) < 2000
end

function Types:is_affected_by_clockwork(type)
    return type >= TYPE_ASSEMBLY_MACHINE and type <= TYPE_ROCKET_SILO
end

function Types:entity_is_affected_by_clockwork(entity)
    local type = self.entity_type_lookup(entity)
    return type >= TYPE_ASSEMBLY_MACHINE and type <= TYPE_ROCKET_SILO
end

Types.subentity_lookup = {
    [SUB_BEACON] = "sosciencity-invisible-beacon",
    [SUB_EEI] = "sosciencity-invisible-eei"
}

function Types:needs_beacon(type)
    return type >= TYPE_ASSEMBLY_MACHINE and type <= TYPE_ROCKET_SILO
end

function Types:needs_eei(type)
    return type < 1000
end

Types.taste_lookup = {
    [TASTE_BITTER] = "bitter",
    [TASTE_NEUTRAL] = "neutral",
    [TASTE_SALTY] = "salty",
    [TASTE_SOUR] = "sour",
    [TASTE_SPICY] = "spicy",
    [TASTE_SWEET] = "sweet",
    [TASTE_UMAMI] = "umami"
}

function Types:needs_neighborhood(type) -- I might need to add more
    return self.is_housing(type)
end
