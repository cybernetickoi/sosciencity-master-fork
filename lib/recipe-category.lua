---------------------------------------------------------------------------------------------------
-- << class for recipe categories >>
Tirislib_RecipeCategory = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib_RecipeCategory.__index = Tirislib_RecipeCategory

--- Class for arrays of recipes. Setter-functions can be called on them.
Tirislib_RecipeCategoryArray = {}
Tirislib_RecipeCategoryArray.__index = Tirislib_PrototypeArray.__index

--- Gets the RecipeCategoryPrototype of the given name. If no such RecipeCategory exists, a dummy object will be returned instead.
--- @param name string
--- @return RecipeCategoryPrototype prototype
--- @return boolean found
function Tirislib_RecipeCategory.get_by_name(name)
    return Tirislib_Prototype.get("recipe-category", name, Tirislib_RecipeCategory)
end

--- Creates the RecipeCategoryPrototype metatable for the given prototype.
--- @param prototype table
--- @return RecipeCategoryPrototype
function Tirislib_RecipeCategory.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib_RecipeCategory)
    return prototype
end

--- Unified function for the get_by_name and for the get_from_prototype functions.
--- @param name string|table
--- @return RecipeCategoryPrototype prototype
--- @return boolean|nil found
function Tirislib_RecipeCategory.get(name)
    if type(name) == "string" then
        return Tirislib_RecipeCategory.get_by_name(name)
    else
        return Tirislib_RecipeCategory.get_from_prototype(name)
    end
end

--- Creates an iterator over all RecipeCategoryPrototype.
--- @return function
--- @return string
--- @return RecipeCategoryPrototype
function Tirislib_RecipeCategory.iterate()
    local index, value

    local function _next()
        index, value = next(data.raw["recipe-category"], index)

        if index then
            setmetatable(value, Tirislib_RecipeCategory)
            return index, value
        end
    end

    return _next, index, value
end

--- Creates an RecipeCategoryPrototype from the given prototype table.
--- @param prototype table
--- @return RecipeCategoryPrototype prototype
function Tirislib_RecipeCategory.create(prototype)
    prototype.type = prototype.type or "recipe-category"

    Tirislib_Prototype.create(prototype)
    return Tirislib_RecipeCategory.get(prototype.name)
end

-- << manipulation >>
--- Entity types that can have crafting categories
local crafters = {"character", "god-controller", "assembling-machine", "furnace", "rocket-silo"}

--- Makes this RecipeCategory craftable by the player.
--- @return RecipeCategoryPrototype itself
function Tirislib_RecipeCategory:make_hand_craftable()
    -- add it to all the prototypes the player can be in
    for _, character in Tirislib_Entity.iterate("character") do
        character:add_crafting_category(self.name)
    end
    for _, controller in Tirislib_Entity.iterate("god-controller") do
        -- technically a god controller isn't an entity, but adding a category works the same for them
        controller:add_crafting_category(self.name)
    end

    return self
end

--- Adds the recipe category to every entity that has also the given category.
--- @param category string
--- @return RecipeCategoryPrototype itself
function Tirislib_RecipeCategory:pair_with(category)
    for _, _type in pairs(crafters) do
        for _, entity in Tirislib_Entity.iterate(_type) do
            if entity:has_crafting_category(category) then
                entity:add_crafting_category(self.name)
            end
        end
    end

    return self
end

local meta = {}

function meta:__call(name)
    return Tirislib_RecipeCategory.get(name)
end

setmetatable(Tirislib_RecipeCategory, meta)
