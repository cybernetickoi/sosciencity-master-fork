Gui = {}

-- this should be added to every element which needs an event handler
-- because the event handler is called for every gui in existance
-- so I need to ensure that I'm not reacting to another mods gui
Gui.UNIQUE_PREFIX = "sosciencity-"
---------------------------------------------------------------------------------------------------
-- << formatting functions >>
local function get_bonus_string(caste_id)
    local bonus = Inhabitants.get_caste_bonus(caste_id)
    if caste_id == TYPE_CLOCKWORK and global.use_penalty then
        bonus = bonus - 80
    end
    return string.format("%+d", bonus)
end

local function get_reasonable_number(number)
    return string.format("%.01d", number)
end

local function get_comfort_localised_string(comfort)
    return {"", comfort .. "  -  ", {"comfort-scale." .. comfort}}
end

local function get_caste_localised_string(caste_id)
    return {"caste-name." .. Types.caste_names[caste_id]}
end

---------------------------------------------------------------------------------------------------
-- << gui elements >>
local DATA_LIST_DEFAULT_NAME = "datalist"
local function add_data_list(container, name)
    local datatable =
        container.add {
        type = "table",
        name = name or DATA_LIST_DEFAULT_NAME,
        column_count = 2,
        style = "bordered_table"
    }
    datatable.style.horizontally_stretchable = true
    datatable.style.vertically_stretchable = true
    datatable.style.right_cell_padding = 8

    return datatable
end

local function add_kv_pair(data_list, key, key_caption, value_caption)
    local key_label =
        data_list.add {
        type = "label",
        name = "key-" .. key,
        caption = key_caption
    }
    key_label.style.font = "default-bold"

    local value_label =
        data_list.add {
        type = "label",
        name = "value-" .. key,
        caption = value_caption
    }
    value_label.style.horizontally_stretchable = true
end

local function get_kv_pair(data_list, key)
    return data_list["key-" .. key], data_list["value-" .. key]
end

local function set_key(data_list, key, key_caption)
    data_list["key-" .. key].caption = key_caption
end

local function set_value(data_list, key, value_caption)
    data_list["value-" .. key].caption = value_caption
end

local function set_padding(element, padding)
    local style = element.style
    style.left_padding = padding
    style.right_padding = padding
    style.top_padding = padding
    style.bottom_padding = padding
end

local function make_stretchable(element)
    element.style.horizontally_stretchable = true
    element.style.vertically_stretchable = true
end

---------------------------------------------------------------------------------------------------
-- << city info gui >>
local CITY_INFO_NAME = "sosciencity-city-info"
local CITY_INFO_SPRITE_SIZE = 48

local function add_population_flow(container)
    local population_count = Inhabitants.get_population_count()

    local frame =
        container.add {
        type = "frame",
        name = "population",
        direction = "vertical"
    }
    frame.style.padding = 0

    local head =
        frame.add {
        type = "label",
        name = "population-head",
        caption = {"sosciencity-gui.population"}
    }
    head.style.horizontal_align = "center"

    local count =
        frame.add {
        type = "label",
        name = "population-count",
        caption = population_count
    }
    count.style.horizontal_align = "center"
end

local function update_population_flow(frame)
    local population_flow = frame["population"]
    local population_count = Inhabitants.get_population_count()

    population_flow["population-count"].caption = population_count
end

local function add_caste_flow(container, caste_id)
    local caste = Types.caste_names[caste_id]

    local frame =
        container.add {
        type = "frame",
        name = "caste-" .. caste_id,
        direction = "vertical"
    }
    frame.style.padding = 0
    frame.style.left_margin = 4

    local sprite =
        frame.add {
        type = "sprite",
        name = "caste-sprite",
        sprite = "technology/" .. caste .. "-caste",
        tooltip = {"caste-name." .. caste}
    }
    sprite.style.height = CITY_INFO_SPRITE_SIZE
    sprite.style.width = CITY_INFO_SPRITE_SIZE
    sprite.style.stretch_image_to_widget_size = true
    sprite.style.horizontal_align = "center"

    local population_label =
        frame.add {
        type = "label",
        name = "caste-population",
        caption = global.population[caste_id],
        tooltip = "population count"
    }
    population_label.style.minimal_width = CITY_INFO_SPRITE_SIZE
    population_label.style.horizontal_align = "center"

    local bonus_label =
        frame.add {
        type = "label",
        name = "caste-bonus",
        caption = {"caste-bonus.display-" .. caste, get_bonus_string(caste_id)},
        tooltip = {"caste-bonus." .. caste}
    }
    bonus_label.style.minimal_width = CITY_INFO_SPRITE_SIZE
    bonus_label.style.horizontal_align = "center"
end

function Gui.create_city_info_for(player)
    local frame = player.gui.top[CITY_INFO_NAME]
    if frame and frame.valid then
        return -- the gui was already created and is still valid
    end

    frame =
        player.gui.top.add {
        type = "flow",
        name = CITY_INFO_NAME,
        direction = "horizontal"
    }

    add_population_flow(frame)

    for id, _ in pairs(Types.caste_names) do
        if Inhabitants.caste_is_researched(id) then
            add_caste_flow(frame, id)
        end
    end
end

local function update_caste_flow(container, caste_id)
    local caste_frame = container["caste-" .. caste_id]

    -- the frame may not yet exist
    if caste_frame == nil then
        add_caste_flow(container, caste_id)
        return
    end

    caste_frame["caste-population"].caption = global.population[caste_id]
    caste_frame["caste-bonus"].caption = {
        "caste-bonus.display-" .. Types.caste_names[caste_id],
        get_bonus_string(caste_id)
    }
end

local function update_city_info(frame)
    update_population_flow(frame)

    for id, _ in pairs(Types.caste_names) do
        if Inhabitants.caste_is_researched(id) then
            update_caste_flow(frame, id)
        end
    end

    frame.visible = (Inhabitants.get_population_count() ~= 0)
end

function Gui.update_city_info()
    for _, player in pairs(game.players) do
        local city_info_gui = player.gui.top[CITY_INFO_NAME]

        -- we check if the gui still exists, as other mods can delete them
        if city_info_gui ~= nil and city_info_gui.valid then
            update_city_info(city_info_gui)
        else
            Gui.create_city_info_for(player)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << entity details view >>
local DETAILS_VIEW_NAME = "sosciencity-details"

local function set_details_view_title(container, caption)
    container.parent.caption = caption
end

-- << empty housing details view >>
local function add_caste_chooser_tab(tabbed_pane, details)
    local tab =
        tabbed_pane.add {
        type = "tab",
        name = "caste",
        caption = {"sosciencity-gui.caste"}
    }
    local flow =
        tabbed_pane.add {
        type = "flow",
        name = "button-flow",
        direction = "vertical"
    }
    make_stretchable(flow)
    flow.style.horizontal_align = "center"
    flow.style.vertical_align = "center"
    flow.style.vertical_spacing = 6

    local at_least_one = false
    for caste_id, caste_name in pairs(Types.caste_names) do
        if Inhabitants.caste_is_researched(caste_id) then
            local button =
                flow.add {
                type = "button",
                name = Gui.UNIQUE_PREFIX .. caste_name,
                caption = {"caste-name." .. caste_name},
                tooltip = {"sosciencity-gui.move-in", caste_name},
                mouse_button_filter = {"left"}
            }
            button.style.width = 150

            if Housing.allowes_caste(details, caste_id) then
                button.tooltip = {"sosciencity-gui.move-in", caste_name}
            elseif Caste(caste_id).required_room_count > details.room_count then
                button.tooltip = {"sosciencity-gui.not-enough-room"}
            else
                button.tooltip = {"sosciencity-gui.not-enough-comfort"}
            end
            button.enabled = Housing.allowes_caste(details, caste_id)
            at_least_one = true
        end
    end

    if not at_least_one then
        flow.add {
            type = "label",
            name = "no-castes-researched-label",
            caption = {"sosciencity-gui.no-castes-researched"}
        }
    end

    tabbed_pane.add_tab(tab, flow)
end

local function add_empty_house_info_tab(tabbed_pane, details)
    local tab =
        tabbed_pane.add {
        type = "tab",
        name = "house",
        caption = {"sosciencity-gui.building-info"}
    }

    local data_list = add_data_list(tabbed_pane, "house-infos")
    add_kv_pair(data_list, "room_count", {"sosciencity-gui.room-count"}, details.room_count)
    add_kv_pair(data_list, "comfort", {"sosciencity-gui.comfort"}, get_comfort_localised_string(details.comfort))

    tabbed_pane.add_tab(tab, data_list)
end

local function create_empty_housing_details(container, entry)
    set_details_view_title(container, entry.entity.localised_name)

    local tab_pane =
        container.add {
        type = "tabbed-pane",
        name = "tabpane"
    }
    make_stretchable(tab_pane)

    local house_details = Housing(entry)
    add_caste_chooser_tab(tab_pane, house_details)
    add_empty_house_info_tab(tab_pane, house_details)
end

-- << housing details view >>
local function add_housing_general_info(tabbed_pane, entry)
    local tab =
        tabbed_pane.add {
        type = "tab",
        name = "general",
        caption = {"sosciencity-gui.general"}
    }

    local data_list = add_data_list(tabbed_pane, "general-infos")
    add_kv_pair(data_list, "caste", {"sosciencity-gui.caste"}, get_caste_localised_string(entry.type))
    add_kv_pair(
        data_list,
        "capacity",
        {"sosciencity-gui.capacity"},
        {"sosciencity-gui.display-capacity", entry.inhabitants, Housing.get_capacity(entry)}
    )
    -- TODO
    add_kv_pair(
        data_list,
        "healthiness",
        {"sosciencity-gui.healthiness"},
        {
            "sosciencity-gui.convergenting-value",
            get_reasonable_number(entry.healthiness),
            get_reasonable_number(entry.healthiness)
        }
    )

    tabbed_pane.add_tab(tab, data_list)
end

local function create_housing_details(container, entry)
    local title = {"", entry.entity.localised_name, "  -  ", get_caste_localised_string(entry.type)}
    set_details_view_title(container, title)

    local tab_pane =
        container.add {
        type = "tabbed-pane",
        name = "tabpane"
    }
    make_stretchable(tab_pane)

    add_housing_general_info(tab_pane, entry)
    -- general info: building, inhabitants, happiness, health, kicking people out
    -- happiness and its sources
    -- health and its sources
end

-- << general details view functions >>
function Gui.create_details_view_for(player)
    local frame = player.gui.screen[DETAILS_VIEW_NAME]
    if frame and frame.valid then
        return
    end

    frame =
        player.gui.screen.add {
        type = "frame",
        name = DETAILS_VIEW_NAME,
        direction = "horizontal"
    }
    frame.style.minimal_width = 250
    frame.style.minimal_height = 300
    set_padding(frame, 4)

    local nested =
        frame.add {
        type = "frame",
        name = "nested",
        direction = "horizontal",
        style = "inside_deep_frame_for_tabs"
    }
    make_stretchable(nested)

    frame.visible = false
end

local function get_details_view(player)
    local details_view = player.gui.screen[DETAILS_VIEW_NAME]

    -- we check if the gui still exists, as other mods can delete them
    if details_view ~= nil and details_view.valid then
        return details_view
    else
        -- recreate it otherwise
        Gui.create_details_view_for(player)
        return get_details_view(player)
    end
end

-- table with (type, update-function) pairs
local content_updaters = {}

function Gui.update_details_view()
    for player_id, unit_number in pairs(global.details_view) do
        local entry = Register.try_get(unit_number)

        -- check if the entity hasn't been unregistered in the meantime
        if not entry then
            Gui.close_details_view_for(game.players[player_id])
        else
            if content_updaters[entry.type] then
                content_updaters[entry.type](get_details_view(game.players[player_id]), entry)
            end
        end
    end
end

-- table with (type, build-function) pairs
local detail_view_builders = {
    [TYPE_EMPTY_HOUSE] = create_empty_housing_details,
    [TYPE_CLOCKWORK] = create_housing_details,
    [TYPE_EMBER] = create_housing_details,
    [TYPE_GUNFIRE] = create_housing_details,
    [TYPE_GLEAM] = create_housing_details,
    [TYPE_FOUNDRY] = create_housing_details,
    [TYPE_ORCHID] = create_housing_details,
    [TYPE_AURORA] = create_housing_details
}

function Gui.open_details_view_for(player, unit_number)
    local details_view = get_details_view(player)
    local entry = Register.try_get(unit_number)
    if not entry then
        return
    end

    if detail_view_builders[entry.type] then
        details_view.nested.clear()
        detail_view_builders[entry.type](details_view.nested, entry)
        details_view.visible = true
        global.details_view[player.index] = unit_number
    end
end

function Gui.close_details_view_for(player)
    local details_view = get_details_view(player)
    details_view.visible = false
    global.details_view[player.index] = nil
    details_view.caption = nil
    details_view.nested.clear()
end

function Gui.rebuild_details_view_for_entry(entry)
    local unit_number = entry.entity.unit_number

    for player_index, viewed_unit_number in pairs(global.details_view) do
        if unit_number == viewed_unit_number then
            local player = game.players[player_index]
            Gui.close_details_view_for(player)
            Gui.open_details_view_for(player, unit_number)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << handlers >>
function Gui.handle_caste_button(player_index, caste_id)
    local entry = Register.try_get(global.details_view[player_index])
    if not entry then
        return
    end

    local changed = Inhabitants.try_allow_for_caste(entry, caste_id)
    if changed then
        Gui.rebuild_details_view_for_entry(entry)
    end
end

---------------------------------------------------------------------------------------------------
-- << general >>
function Gui.create_guis_for(player)
    Gui.create_city_info_for(player)
    Gui.create_details_view_for(player)
end

function Gui.init()
    global.details_view = {}

    for _, player in pairs(game.players) do
        Gui.create_guis_for(player)
    end
end

return Gui
