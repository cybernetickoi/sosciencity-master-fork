---------------------------------------------------------------------------------------------------
-- << items >>
local flora_items = {
    {name = "leafage", sprite_variations = {name = "leafage", count = 3, include_icon = true}},
    {name = "plemnemm-cotton", sprite_variations = {name = "plemnemm-cotton-pile", count = 4}},
    {name = "phytofall-blossom"},
    {name = "tiriscefing-willow-wood", distinctions = {fuel_value = "1MJ", fuel_category = "chemical"}},
    {name = "cherry-wood", distinctions = {fuel_value = "1MJ", fuel_category = "chemical"}},
    {name = "olive-wood", distinctions = {fuel_value = "1MJ", fuel_category = "chemical"}},
    {name = "avocado-wood", distinctions = {fuel_value = "1MJ", fuel_category = "chemical"}}
}

Tirislib_Item.batch_create(flora_items, {subgroup = "sosciencity-flora", stack_size = 200})

---------------------------------------------------------------------------------------------------
-- << gathering recipes >>

---------------------------------------------------------------------------------------------------
-- << farming recipes >>
--- Table with (product, table of recipe specification) pairs
local farmables = {
    ["avocado"] = {
        general = {
            energy_required = 30,
            byproducts = {{type = "item", name = "avocado-wood", amount = 1, probability = 0.2}}
        },
        arboretum = {},
        orangery = {}
    },
    ["bell-pepper"] = {
        general = {
            energy_required = 100,
            unlock = "nightshades"
        },
        agriculture = {},
        greenhouse = {}
    },
    ["brutal-pumpkin"] = {
        general = {
            energy_required = 100
        },
        agriculture = {
            product_min = 5,
            product_max = 50,
            product_probability = 0.5
        },
        greenhouse = {
            product_min = 40,
            product_max = 60
        }
    },
    ["cherry"] = {
        general = {
            energy_required = 20,
            byproducts = {{type = "item", name = "cherry-wood", amount = 1, probability = 0.2}}
        },
        arboretum = {},
        orangery = {}
    },
    ["olive"] = {
        general = {
            energy_required = 20,
            byproducts = {{type = "item", name = "olive-wood", amount = 1, probability = 0.2}}
        },
        arboretum = {},
        orangery = {}
    },
    ["potato"] = {
        general = {
            energy_required = 100,
            unlock = "nightshades"
        },
        agriculture = {
            product_min = 5,
            product_max = 50
        },
        greenhouse = {
            product_min = 40,
            product_max = 60
        }
    },
    ["tomato"] = {
        general = {
            energy_required = 150,
            unlock = "nightshades"
        },
        agriculture = {
            product_min = 5,
            product_max = 50
        },
        greenhouse = {
            product_min = 40,
            product_max = 60
        }
    },
    ["eggplant"] = {
        general = {
            energy_required = 150,
            unlock = "nightshades"
        },
        agriculture = {
            product_min = 5,
            product_max = 50
        },
        greenhouse = {
            product_min = 40,
            product_max = 60
        }
    },
    ["plemnemm-cotton"] = {
        general = {
            energy_required = 60
        },
        agriculture = {
            product_min = 10,
            product_max = 20
        },
        greenhouse = {
            product_min = 20,
            product_max = 30
        }
    },
    ["tiriscefing-willow-wood"] = {
        arboretum = {
            energy_required = 20,
            product_probability = 1,
            product_min = 5,
            product_max = 15,
            byproducts = {{type = "item", name = "fawoxylas", amount = 2, probability = 0.5}}
        }
    },
    ["unnamed-fruit"] = {
        general = {
            energy_required = 100
        },
        agriculture = {
            product_min = 5,
            product_max = 50
        },
        greenhouse = {
            product_min = 40,
            product_max = 60
        }
    }
}

local farm_specific_defaults = {
    agriculture = {
        product_probability = 0.5
    },
    arboretum = {
        product_probability = 0.5,
        byproducts = {{type = "item", name = "leafage", amount = 1}}
    },
    greenhouse = {},
    orangery = {
        byproducts = {{type = "item", name = "leafage", amount = 1}}
    }
}

-- generation code that should minimize dublications
local attributes = {"product_probability"}
local function merge_specification_details(lh, rh)
    for _, attribute in pairs(attributes) do
        lh[attribute] = lh[attribute] or rh[attribute] or nil
    end

    if rh.byproducts then
        local byproducts = Tirislib_Tables.get_inner_table(lh, "byproducts")
        Tirislib_Tables.merge_arrays(byproducts, rh.byproducts)
    end
end

local function merge_with_general_product_specification(specification, product)
    local general = farmables[product]["general"]

    if general then
        merge_specification_details(specification, general)
    end
end

local function add_main_theme(specification)
    local main_theme = {"agriculture", specification.energy_required or 0.5, specification.level}
    local themes = Tirislib_Tables.get_inner_table(specification, "themes")
    themes[#themes + 1] = main_theme
end

local function merge_with_category_specification(specification, category)
    local category_table = farm_specific_defaults[category]
    merge_specification_details(specification, category_table)
end

local function create_farming_recipe(product, category, specification)
    merge_with_general_product_specification(specification, product)
    merge_with_category_specification(specification, category)
    add_main_theme(specification)

    specification.product = product
    specification.category = "sosciencity-" .. category

    Tirislib_RecipeGenerator.create(specification)
end

-- create the recipes
for product, details in pairs(farmables) do
    for category, specification in pairs(details) do
        if category ~= "general" then
            create_farming_recipe(product, category, specification)
        end
    end
end
