---------------------------------------------------------------------------------------------------
-- << class for fluids >>
Tirislib_Fluid = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib_Fluid.__index = Tirislib_Fluid

--- Class for arrays of fluids. Setter-functions can be called on them.
Tirislib_FluidArray = {}
Tirislib_FluidArray.__index = Tirislib_PrototypeArray.__index

--- Gets the FluidPrototype of the given name. If no such Fluid exists, a dummy object will be returned instead.
--- @param name string
--- @return FluidPrototype prototype
--- @return boolean found
function Tirislib_Fluid.get_by_name(name)
    return Tirislib_Prototype.get("fluid", name, Tirislib_Fluid)
end

--- Creates the FluidPrototype metatable for the given prototype.
--- @param prototype table
--- @return FluidPrototype
function Tirislib_Fluid.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib_Fluid)
    return prototype
end

--- Unified function for the get_by_name and for the get_from_prototype functions.
--- @param name string|table
--- @return FluidPrototype prototype
--- @return boolean|nil found
function Tirislib_Fluid.get(name)
    if type(name) == "string" then
        return Tirislib_Fluid.get_by_name(name)
    else
        return Tirislib_Fluid.get_from_prototype(name)
    end
end

--- Creates an iterator over all FluidPrototypes.
--- @return function
--- @return string
--- @return FluidPrototype
function Tirislib_Fluid.iterate()
    local index, value

    local function _next()
        index, value = next(data.raw["fluid"], index)

        if index then
            setmetatable(value, Tirislib_Fluid)
            return index, value
        end
    end

    return _next, index, value
end

--- Creates an FluidPrototype from the given prototype table.
--- @param prototype table
--- @return FluidPrototype prototype
function Tirislib_Fluid.create(prototype)
    if not prototype.type then
        prototype.type = "fluid"
    end

    data:extend {prototype}
    return Tirislib_Fluid.get(prototype.name)
end

--- Creates a bunch of fluid prototypes.\
--- *Fluid specification:*\
--- **name:** name of the fluid prototype\
--- **distinctions:** table of prototype fields that should be different from the batch specification
--- @param fluid_detail_array table
--- @param batch_details table
--- @return FluidPrototypeArray
function Tirislib_Fluid.batch_create(fluid_detail_array, batch_details)
    local path = batch_details.icon_path or "__sosciencity-graphics__/graphics/icon/"
    local size = batch_details.icon_size or 64
    local subgroup = batch_details.subgroup
    local base_color = batch_details.base_color
    local flow_color = batch_details.flow_color or base_color
    local default_temperature = batch_details.default_temperature or 10
    local max_temperature = batch_details.max_temperature or 100

    local created_items = {}
    for index, details in pairs(fluid_detail_array) do
        local fluid =
            Tirislib_Fluid.create {
            name = details.name,
            icon = path .. details.name .. ".png",
            icon_size = size,
            subgroup = subgroup,
            order = string.format("%03d", index),
            default_temperature = default_temperature,
            max_temperature = max_temperature,
            base_color = base_color,
            flow_color = flow_color
        }

        Tirislib_Tables.set_fields(fluid, details.distinctions)

        created_items[#created_items + 1] = fluid
    end

    setmetatable(created_items, Tirislib_FluidArray)
    return created_items
end

local meta = {}

function meta:__call(name)
    return Tirislib_Fluid.get(name)
end

setmetatable(Tirislib_Fluid, meta)
