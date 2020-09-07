require("lib.init")

item_operations = {}
recipe_operations = {}

require("datastage-scripts.science-pack-ingredients")
require("datastage-scripts.launchable-items")
require("datastage-scripts.gunfire-techs")
require("datastage-scripts.loot")
require("datastage-scripts.fawoxylas")

--<< looping through items >>
local item_types = require("lib.prototype-types.item-types")

for _, item_type in pairs(item_types) do
    for _, current_item in Tirislib_Item.pairs(item_type) do
        for _, operation in pairs(item_operations) do
            operation.func(current_item, operation.details)
        end
    end
end

--<< looping through recipes >>
for _, current_recipe in Tirislib_Recipe.pairs() do
    for _, operation in pairs(recipe_operations) do
        operation.func(current_recipe, operation.details)
    end
end

--<< handcrafting category >>
Tirislib_RecipeCategory("handcrafting"):make_hand_craftable()
Tirislib_RecipeCategory("sosciencity-architecture"):make_hand_craftable()
Tirislib_RecipeCategory("sosciencity-hunting"):make_hand_craftable()
Tirislib_RecipeCategory("sosciencity-slaughter"):pair_with("crafting")

Tirislib_Prototype.finish()
