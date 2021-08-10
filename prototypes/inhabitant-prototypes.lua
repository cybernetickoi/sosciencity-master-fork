require("constants.biology")

---------------------------------------------------------------------------------------------------
-- << items >>

local items = {
    {
        name = "huwan-egg",
        sprite_variations = {name = "huwan-egg", count = 4, include_icon = true},
        distinctions = {
            localised_name = {"item-name.huwan-egg"},
            localised_description = {"item-description.huwan-egg", {"sosciencity.any"}}
        }
    },
    {
        name = "huwan-neutral-egg",
        sprite_variations = {name = "huwan-neutral-egg", count = 4, include_icon = true},
        distinctions = {
            localised_name = {"item-name.huwan-egg"},
            localised_description = {"item-description.huwan-egg", {"sosciencity.gender-1"}}
        }
    },
    {
        name = "huwan-fale-egg",
        sprite_variations = {name = "huwan-fale-egg", count = 4, include_icon = true},
        distinctions = {
            localised_name = {"item-name.huwan-egg"},
            localised_description = {"item-description.huwan-egg", {"sosciencity.gender-2"}}
        }
    },
    {
        name = "huwan-pachin-egg",
        sprite_variations = {name = "huwan-pachin-egg", count = 4, include_icon = true},
        distinctions = {
            localised_name = {"item-name.huwan-egg"},
            localised_description = {"item-description.huwan-egg", {"sosciencity.gender-3"}}
        }
    },
    {
        name = "huwan-ga-egg",
        sprite_variations = {name = "huwan-ga-egg", count = 4, include_icon = true},
        distinctions = {
            localised_name = {"item-name.huwan-egg"},
            localised_description = {"item-description.huwan-egg", {"sosciencity.gender-4"}}
        }
    }
}

Tirislib_Item.batch_create(items, {subgroup = "sosciencity-inhabitants", stack_size = 10})

Tirislib_Recipe.create {
    name = "lay-egg",
    category = "sosciencity-handcrafting",
    enabled = true,
    energy_required = 5,
    ingredients = {},
    results = {
        {type = "item", name = "huwan-neutral-egg", amount_min = 1, amount_max = 3}
    },
    icon = "__sosciencity-graphics__/graphics/icon/huwan-neutral-egg.png",
    icon_size = 64,
    subgroup = "sosciencity-inhabitants",
    main_product = "",
    localised_description = {"recipe-description.lay-egg", Biology.egg_calories}
}:add_unlock("clockwork-caste")

for index, egg in pairs({"huwan-fale-egg", "huwan-pachin-egg", "huwan-ga-egg"}) do
    Tirislib_RecipeGenerator.create {
        product = egg,
        energy_required = 120,
        expensive_energy_required = 160,
        ingredients = {
            {type = "item", name = "huwan-genome", amount = 1}
        },
        themes = {{"genetical", 1}},
        category = "sosciencity-reproductive-gene-lab",
        localised_name = {"recipe-name.in-vitro-reproduction", {"sosciencity.gender-" .. (index + 1)}},
        unlock = "huwan-genetic-neogenesis"
    }
end
