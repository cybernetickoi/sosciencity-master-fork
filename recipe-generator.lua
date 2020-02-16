---------------------------------------------------------------------------------------------------
-- << static class for recipe generation >>
-- generic recipes with configurable ingredients to facilitate integration/compatibility with other mods
-- assumes the result items already exist
Tirislib_RecipeGenerator = {}

-- shorthand alias for more readability
local RG = Tirislib_RecipeGenerator

-- table with tech_level -> array of IngredientPrototypes
-- 0: Start of the game, nothing researched
-- 1: automation science
-- 2: logistic science
-- 3: chemical science
-- 4: production science
-- 5: utility science
-- 6: space science
-- 7: post space science
RG.room_ingredients = {
    [0] = {
        {type = "item", name = "lumber", amount = 2},
        {type = "item", name = "iron-plate", amount = 4}
    },
    [1] = {
        {type = "item", name = "lumber", amount = 2},
        {type = "item", name = "iron-plate", amount = 6},
        {type = "item", name = "stone-brick", amount = 5}
    },
    [2] = {
        {type = "item", name = "lumber", amount = 4},
        {type = "item", name = "iron-plate", amount = 8},
        {type = "item", name = "stone-brick", amount = 10}
    },
    [3] = {
        {type = "item", name = "steel-plate", amount = 5},
        {type = "item", name = "stone-brick", amount = 10},
        {type = "item", name = "mineral-wool", amount = 2}
    },
    [4] = {
        {type = "item", name = "steel-plate", amount = 6},
        {type = "item", name = "concrete", amount = 10},
        {type = "item", name = "mineral-wool", amount = 2}
    },
    [5] = {
        {type = "item", name = "steel-plate", amount = 6},
        {type = "item", name = "concrete", amount = 10},
        {type = "item", name = "mineral-wool", amount = 2}
    },
    [6] = {
        {type = "item", name = "steel-plate", amount = 8},
        {type = "item", name = "refined-concrete", amount = 10},
        {type = "item", name = "mineral-wool", amount = 2}
    },
    [7] = {
        {type = "item", name = "steel-plate", amount = 8},
        {type = "item", name = "refined-concrete", amount = 10},
        {type = "item", name = "mineral-wool", amount = 2}
    }
}

RG.housing_unlocking_tech = {
    [0] = nil,
    [1] = "architecture-1",
    [2] = "architecture-2",
    [3] = "architecture-3",
    [4] = "architecture-4",
    [5] = "architecture-5",
    [6] = "architecture-6",
    [7] = "architecture-7"
}

-- table with comfort -> array of IngredientPrototypes
RG.furniture_ingredients = {
    [0] = {},
    [1] = {
        {type = "item", name = "stool", amount = 2},
        {type = "item", name = "table", amount = 1}
    },
    [2] = {
        {type = "item", name = "bed", amount = 1}
    },
    [3] = {
        {type = "item", name = "furniture", amount = 2},
        {type = "item", name = "stool", amount = 2}
    },
    [4] = {},
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {},
    [9] = {},
    [10] = {}
}

-- table with item_name -> array of IngredientPrototypes
RG.ingredients = {
    ["farm"] = {
        {type = "item", name = "stone", amount = 25},
        {type = "item", name = "stone-brick", amount = 10},
        {type = "item", name = "pipe", amount = 10}
    },
    ["greenhouse"] = {
        {type = "item", name = "lumber", amount = 150},
        {type = "item", name = "stone-brick", amount = 150},
        {type = "item", name = "pipe", amount = 150},
        {type = "item", name = "steel-plate", amount = 100},
        {type = "item", name = "small-lamp", amount = 50},
        {type = "item", name = "electronic-circuit", amount = 20}
    }
}

RG.agriculture_growing_ingredients = {
    {type = "fluid", name = "water", amount = 500}
}

RG.greenhouse_growing_ingredients = {
    {type = "fluid", name = "water", amount = 500}
}

RG.orangery_growing_ingredients = {
    {type = "fluid", name = "water", amount = 500}
}

RG.arboretum_growing_ingredients = {
    {type = "fluid", name = "water", amount = 500}
}

RG.expensive_multiplier = 3
RG.expensive_farming_multiplier = 1.5
RG.expensive_farming_energy_multiplier = 1.2

RG.agriculture_time = 120
RG.greenhouse_time = 100
RG.orangery_time = 20
RG.arboretum_time = 30

function RG.create_housing_recipe(housing_name, details)
    local item = Tirislib_Item.get(housing_name)

    local recipe =
        Tirislib_Recipe.create {
        name = housing_name,
        category = "crafting",
        enabled = (details.tech_level == 0),
        results = {
            {type = "item", name = housing_name, amount = 1}
        },
        subgroup = item.subgroup,
        order = item.order,
        main_product = housing_name
    }:create_difficulties()

    local room_ingredients = RG.room_ingredients[details.tech_level]
    recipe:add_ingredient_range(room_ingredients)
    recipe:multiply_expensive_ingredients(RG.expensive_multiplier)

    for _ = 0, details.comfort do
        local furniture = RG.furniture_ingredients[details.comfort]
        recipe:add_ingredient_range(furniture)
    end

    recipe:multiply_ingredients(details.room_count)

    return recipe
end

function RG.create_recipe(product_name, ingredients, additional_fields)
    local item = Tirislib_Item.get(product_name)

    local recipe =
        Tirislib_Recipe.create {
        name = product_name,
        category = "crafting",
        enabled = true,
        results = {
            {type = "item", name = product_name, amount = 1}
        },
        subgroup = item.subgroup,
        order = item.order,
        main_product = product_name
    }:create_difficulties()

    recipe:add_ingredient_range(ingredients)
    recipe:add_ingredient_range(RG.ingredients[product_name])
    recipe:multiply_expensive_ingredients(RG.expensive_multiplier)

    Tirislib_Tables.set_fields(recipe, additional_fields)

    return recipe
end

function RG.create_agriculture_recipe(product_name, yield, ingredients, additional_fields)
    local recipe =
        Tirislib_Recipe.create {
        name = product_name .. "-agriculture",
        category = "sosciencity-agriculture",
        enabled = true,
        energy_required = RG.agriculture_time,
        results = {
            {type = "item", name = product_name, amount_min = 1, amount_max = yield, probability = 0.5}
        },
        subgroup = "sosciencity-agriculture",
        show_amount_in_title = false,
        always_show_products = true
    }:create_difficulties()

    recipe:add_ingredient_range(ingredients)
    recipe:add_ingredient_range(RG.agriculture_growing_ingredients)
    recipe:multiply_expensive_ingredients(RG.expensive_farming_multiplier)
    recipe:multiply_expensive_field("energy_required", RG.expensive_farming_energy_multiplier)

    Tirislib_Tables.set_fields(recipe, additional_fields)

    return recipe
end

function RG.create_greenhouse_recipe(product_name, yield, ingredients, additional_fields)
    local min_yield = math.min(math.floor(yield / 2))

    local recipe =
        Tirislib_Recipe.create {
        name = product_name .. "-greenhouse",
        category = "sosciencity-greenhouse",
        enabled = true,
        energy_required = RG.greenhouse_time,
        results = {
            {type = "item", name = product_name, amount_min = min_yield, amount_max = yield}
        },
        subgroup = "sosciencity-greenhouse",
        show_amount_in_title = false,
        always_show_products = true
    }:create_difficulties()

    recipe:add_ingredient_range(ingredients)
    recipe:add_ingredient_range(RG.greenhouse_growing_ingredients)
    recipe:multiply_expensive_ingredients(RG.expensive_farming_multiplier)
    recipe:multiply_expensive_field("energy_required", RG.expensive_farming_energy_multiplier)

    Tirislib_Tables.set_fields(recipe, additional_fields)

    return recipe
end

function RG.create_orangery_recipe(product_name, yield, ingredients, additional_fields)
    local recipe =
        Tirislib_Recipe.create {
        name = product_name .. "-orangery",
        category = "sosciencity-orangery",
        enabled = true,
        energy_required = RG.greenhouse_time,
        results = {
            {type = "item", name = product_name, amount_min = math.floor(yield / 2.), amount_max = yield}
        },
        subgroup = "sosciencity-orangery",
        show_amount_in_title = false,
        always_show_products = true
    }:create_difficulties()

    recipe:add_ingredient_range(ingredients)
    recipe:add_ingredient_range(RG.orangery_growing_ingredients)
    recipe:multiply_expensive_ingredients(RG.expensive_farming_multiplier)
    recipe:multiply_expensive_field("energy_required", RG.expensive_farming_energy_multiplier)

    Tirislib_Tables.set_fields(recipe, additional_fields)

    return recipe
end

function RG.create_arboretum_recipe(product_name, yield, ingredients, additional_fields)
    local recipe = Tirislib_Recipe.create {
        name = product_name .. "-arboretum",
        category = "sosciencity-arboretum",
        enabled = true,
        energy_required = RG.arboretum_time,
        results = {
            {type = "item", name = product_name, amount_min = math.floor(yield / 2.), amount_max = yield}
        },
        subgroup = "sosciencity-arboretum",
        show_amount_in_title = false,
        always_show_products = true
    }:create_difficulties()

    recipe:add_ingredient_range(ingredients)
    recipe:add_ingredient_range(RG.arboretum_growing_ingredients)
    recipe:multiply_expensive_ingredients(RG.expensive_farming_multiplier)
    recipe:multiply_expensive_field("energy_required", RG.expensive_farming_energy_multiplier)

    Tirislib_Tables.set_fields(recipe, additional_fields)

    return recipe
end