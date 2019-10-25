require("lib.init")

item_operations = {}
recipe_operations = {}

require("scripts.data-updates.science-pack-ingredients")
require("scripts.data-updates.launchable-items")
require("scripts.data-updates.gunfire-techs")
require("scripts.data-updates.loot")

--<< looping through items >>
local item_types = require("lib.prototype-types.item-types")

for _, item_type in pairs(item_types) do
    for item_name, _ in pairs(data.raw[item_type]) do
        local current_item = Item:get_by_name(item_name)

        for _, operation in pairs(item_operations) do
            operation.func(current_item, operation.details)
        end
    end
end

--<< looping through recipes >>
for recipe_name, _ in pairs(data.raw.recipe) do
    local current_recipe = Recipe:get_by_name(recipe_name)

    for _, operation in pairs(recipe_operations) do
        operation.func(current_recipe, operation.details)
--[[
        local status, err = pcall(operation.func, current_recipe, operation.details)

        if not status then
            error(err .. "\n" .. serpent.block(operation) .. "\nrecipe:\n" .. serpent.block(current_recipe))
        end]]
    end
end

--<< handcrafting category >>
-- add it when no other mod did so
if not data.raw["recipe-category"]["handcrafting"] then
    data:extend {
        {
            type = "recipe-category",
            name = "handcrafting"
        }
    }

    for _, character in pairs(data.raw["character"]) do
        Entity.add_crafting_category(character, "handcrafting")
    end
    for _, controller in pairs(data.raw["god-controller"]) do
        -- technically a god controller isn't an entity, but adding a category works the same for them
        Entity.add_crafting_category(controller, "handcrafting")
    end
end
