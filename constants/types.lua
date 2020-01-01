---------------------------------------------------------------------------------------------------
-- << enums >>
-- (except that lua doesn't have enums and all these are just shouty globals)
--<< entities >>
TYPE_EMPTY_HOUSE = 0
TYPE_CLOCKWORK = 1
TYPE_ORCHID = 2
TYPE_GUNFIRE = 3
TYPE_EMBER = 4
TYPE_FOUNDRY = 5
TYPE_GLEAM = 6
TYPE_AURORA = 7
TYPE_PLASMA = 8

TYPE_MARKET = 101
TYPE_WATER_DISTRIBUTION_FACILITY = 102
TYPE_HOSPITAL = 103
TYPE_PHARMACY = 104

TYPE_CLUB = 201
TYPE_SCHOOL = 202
TYPE_BARRACK = 203
TYPE_UNIVERSITY = 204
TYPE_UNIVERSITY_MK02 = 205
TYPE_CITY_HALL = 206
TYPE_RESEARCH_CENTER = 207

TYPE_ASSEMBLING_MACHINE = 1001
TYPE_FURNACE = 1002
TYPE_ROCKET_SILO = 1003
TYPE_MINING_DRILL = 1004
TYPE_FARM = 1005
TYPE_ORANGERY = 1006

TYPE_TURRET = 1100

TYPE_LAB = 2002

TYPE_NULL = 9999

--<< subentities >>
SUB_BEACON = 10001
SUB_EEI = 10002
SUB_ALT_MODE_SPRITE = 10003

--<< tastes >>
TASTE_BITTER = 20001
TASTE_NEUTRAL = 20002
TASTE_SALTY = 20003
TASTE_SOUR = 20004
TASTE_SPICY = 20005
TASTE_SWEET = 20006
TASTE_UMAMI = 20007

--<< entry keys >>
-- general
TYPE = 1
ENTITY = 2
LAST_UPDATE = 3
SUBENTITIES = 4
SPRITE = 5
-- housing
INHABITANTS = 6
HAPPINESS = 7
HAPPINESS_FACTORS = 8
HEALTH = 9
HEALTH_FACTORS = 10
MENTAL_HEALTH = 11
MENTAL_HEALTH_FACTORS = 12
TREND = 13
IDEAS = 14
NEIGHBORHOOD = 15
-- subentity stuff
ENERGY_USAGE = 16
SPEED_BONUS = 17
PRODUCTIVITY_BONUS = 18
HAS_PENALTY = 19
TICK_OF_CREATION = 20

--<< happiness factors >>
HAPPINESS_HOUSING = 1
HAPPINESS_TASTE = 2
HAPPINESS_FOOD_LUXURY = 3
HAPPINESS_HUNGER = 4
HAPPINESS_NO_POWER = 5
HAPPINESS_POWER = 6
HAPPINESS_STRESS = 7

--<< health factors >>
HEALTH_NUTRIENTS = 1
HEALTH_FOOD = 2
HEALTH_STRESS = 3
HEALTH_HUNGER = 4

--<< mental health factors >>
MENTAL_HEALTH_HOUSING = 1
MENTAL_HEALTH_TASTE = 2
MENTAL_HEALTH_FAV_TASTE = 3
MENTAL_HEALTH_NO_VARIETY = 4
MENTAL_HEALTH_LEAST_FAV_TASTE = 5
MENTAL_HEALTH_JUST_NEUTRAL = 6
MENTAL_HEALTH_SINGLE_FOOD = 7
MENTAL_HEALTH_NO_FOOD = 8
MENTAL_HEALTH_STRESS = 9
MENTAL_HEALTH_HUNGER = 10

---------------------------------------------------------------------------------------------------
-- << type functions >>
Types = {}
Types.entity_type_lookup = {
    types = {
        ["assembling-machine"] = TYPE_ASSEMBLING_MACHINE,
        ["mining-drill"] = TYPE_MINING_DRILL,
        ["lab"] = TYPE_LAB,
        ["rocket-silo"] = TYPE_ROCKET_SILO,
        ["furnace"] = TYPE_FURNACE,
        ["ammo-turret"] = TYPE_TURRET,
        ["electric-turret"] = TYPE_TURRET,
        ["fluid-turret"] = TYPE_TURRET,
        ["turret"] = TYPE_TURRET
    },
    names = {
        ["greenhouse"] = TYPE_FARM
    }
}

Types.taste_names = {
    [TASTE_BITTER] = "bitter",
    [TASTE_NEUTRAL] = "neutral",
    [TASTE_SALTY] = "salty",
    [TASTE_SOUR] = "sour",
    [TASTE_SPICY] = "spicy",
    [TASTE_SWEET] = "sweet",
    [TASTE_UMAMI] = "umami"
}

Types.type_sprite_pairs = {
    [TYPE_EMPTY_HOUSE] = "empty-caste",
    [TYPE_CLOCKWORK] = "clockwork-caste",
    [TYPE_EMBER] = "ember-caste",
    [TYPE_GUNFIRE] = "gunfire-caste",
    [TYPE_GLEAM] = "gleam-caste",
    [TYPE_FOUNDRY] = "foundry-caste",
    [TYPE_ORCHID] = "orchid-caste",
    [TYPE_AURORA] = "aurora-caste"
}

function Types.get_entity_type(entity)
    local name = entity.name
    if Housing.houses[name] then
        return TYPE_EMPTY_HOUSE
    end

    return Types.entity_type_lookup.names[name] or Types.entity_type_lookup.types[entity.type] or TYPE_NULL
end

function Types.is_housing(_type)
    return _type < 100
end

function Types.is_inhabited(_type)
    return (_type < 100) and (_type ~= 0)
end

function Types.is_civil(_type)
    return _type < 1000
end

function Types.is_relevant_to_register(_type)
    return _type < 2000
end

function Types.is_affected_by_clockwork(_type)
    return (_type >= TYPE_ASSEMBLING_MACHINE) and (_type <= TYPE_ORANGERY)
end

function Types.is_affected_by_orchid(_type)
    return (_type >= TYPE_FARM) and (_type <= TYPE_ORANGERY)
end

function Types.needs_beacon(_type)
    return (_type >= TYPE_ASSEMBLING_MACHINE) and (_type <= TYPE_ORANGERY)
end

function Types.needs_eei(_type)
    return _type < 1000
end

function Types.needs_alt_mode_sprite(_type)
    return _type < 100
end

function Types.needs_neighborhood(_type) -- I might need to add more
    return Types.is_housing(_type)
end

local meta = {}

function meta:__call(entity)
    return Types.get_entity_type(entity)
end

setmetatable(Types, meta)
