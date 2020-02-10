Gui = {}

local castes = Caste.values
local global
local population
local effective_population

local function set_locals()
    global = _ENV.global
    population = global.population
    effective_population = global.effective_population
end
-- this should be added to every element which needs an event handler
-- because the event handler is called for every gui in existance
-- so I need to ensure that I'm not reacting to another mods gui
Gui.UNIQUE_PREFIX = "sosciencity-"
---------------------------------------------------------------------------------------------------
-- << formatting functions >>
local function get_bonus_string(caste_id)
    local bonus = global.caste_bonuses[caste_id]
    if caste_id == Type.clockwork and global.use_penalty then
        bonus = bonus - 80
    end
    return string.format("%+d", bonus)
end

local function get_reasonable_number(number)
    return string.format("%.1f", number)
end

local function get_summand_string(number)
    if number > 0 then
        return string.format("[color=0,1,0]%+.1f[/color]", number)
    elseif number < 0 then
        return string.format("[color=1,0,0]%+.1f[/color]", number)
    else -- number equals 0
        return "[color=0.8,0.8,0.8]0.0[/color]"
    end
end

local function get_factor_string(number)
    if number > 1 then
        return string.format("[color=0,1,0]×%.1f[/color]", number)
    elseif number < 1 then
        return string.format("[color=1,0,0]×%.1f[/color]", number)
    else -- number equals 1
        return "[color=0.8,0.8,0.8]1.0[/color]"
    end
end

local function get_comfort_localised_string(comfort)
    return {"", comfort, "  -  ", {"comfort-scale." .. comfort}}
end

local function get_caste_localised_string(caste_id)
    return {"caste-name." .. castes[caste_id].name}
end

local function get_convergence_localised_string(current, target)
    return {"sosciencity-gui.convergenting-value", get_reasonable_number(current), get_reasonable_number(target)}
end

local function get_migration_string(number)
    return string.format("%+.1f", number)
end

---------------------------------------------------------------------------------------------------
-- << style functions >>
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

local function make_squashable(element)
    element.style.horizontally_squashable = true
    element.style.vertically_squashable = true
end

---------------------------------------------------------------------------------------------------
-- << gui elements >>
local DATA_LIST_DEFAULT_NAME = "datalist"
local function create_data_list(container, name)
    local datatable =
        container.add {
        type = "table",
        name = name or DATA_LIST_DEFAULT_NAME,
        column_count = 2,
        style = "bordered_table"
    }
    local style = datatable.style
    style.horizontally_stretchable = true
    style.right_cell_padding = 6
    style.left_cell_padding = 6

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
        name = key,
        caption = value_caption
    }
    local style = value_label.style
    style.horizontally_stretchable = true
    style.single_line = false
end

local function get_kv_pair(data_list, key)
    return data_list["key-" .. key], data_list[key]
end

local function set_key(data_list, key, key_caption)
    data_list["key-" .. key].caption = key_caption
end

local function set_datalist_value(data_list, key, value_caption)
    data_list[key].caption = value_caption
end

local function set_datalist_value_tooltip(datalist, key, tooltip)
    datalist[key].tooltip = tooltip
end

local function set_ks_pair_visibility(datalist, key, visibility)
    datalist["key-" .. key].visible = visibility
    datalist[key].visible = visibility
end

local function add_final_value_entry(data_list, caption)
    local sum_key =
        data_list.add {
        type = "label",
        name = "key-sum",
        caption = caption
    }
    local style = sum_key.style
    style.font = "default-bold"
    style.horizontally_stretchable = true

    local sum_value =
        data_list.add {
        type = "label",
        name = "sum"
    }
    style = sum_value.style
    style.width = 50
    style.font = "default-bold"
    style.horizontal_align = "right"
end

local function add_operand_entry(data_list, key, key_caption, value_caption)
    data_list.add {
        type = "label",
        name = "key-" .. key,
        caption = key_caption
    }

    local value_label =
        data_list.add {
        type = "label",
        name = key,
        caption = value_caption
    }
    local style = value_label.style
    style.horizontal_align = "right"
    style.width = 50
end

local function add_summand_entries(data_list, caption_group, count)
    for i = 1, count do
        add_operand_entry(data_list, tostring(i), {caption_group .. i})
    end
end

local function add_factor_entries(data_list, caption_group, count)
    for i = 1, count do
        add_operand_entry(data_list, "*" .. i, {caption_group .. i})
    end
end

local function create_operand_entries(data_list, caption, summand_caption, summand_count, factor_caption, factor_count)
    add_final_value_entry(data_list, caption)
    add_summand_entries(data_list, summand_caption, summand_count)
    add_factor_entries(data_list, factor_caption, factor_count)
end

local function update_operand_entries(data_list, final_value, summand_entries, factor_entries)
    data_list["sum"].caption = get_summand_string(final_value)

    for i = 1, #summand_entries do
        local value = summand_entries[i]
        local key = tostring(i)

        if value ~= 0 then
            set_datalist_value(data_list, key, get_summand_string(value))
            set_ks_pair_visibility(data_list, key, true)
        else
            set_ks_pair_visibility(data_list, key, false)
        end
    end

    for i = 1, #factor_entries do
        local value = factor_entries[i]
        local key = "*" .. i

        if value ~= 1. then
            set_datalist_value(data_list, key, get_factor_string(value))
            set_ks_pair_visibility(data_list, key, true)
        else
            set_ks_pair_visibility(data_list, key, false)
        end
    end
end

local function is_confirmed(button)
    local caption = button.caption[1]
    if caption == "sosciencity-gui.confirm" then
        return true
    else
        button.caption = {"sosciencity-gui.confirm"}
        button.tooltip = {"sosciencity-gui.confirm-tooltip"}
        return false
    end
end

local function create_caste_sprite(container, caste_id, size)
    local caste_name = castes[caste_id].name

    local sprite =
        container.add {
        type = "sprite",
        name = "caste-sprite",
        sprite = "technology/" .. caste_name .. "-caste",
        tooltip = {"caste-name." .. caste_name}
    }
    local style = sprite.style
    style.height = size
    style.width = size
    style.stretch_image_to_widget_size = true

    return sprite
end

local function create_tab(tabbed_pane, name, caption)
    local tab =
        tabbed_pane.add {
        type = "tab",
        name = name .. "tab",
        caption = caption
    }
    local scrollpane =
        tabbed_pane.add {
        type = "scroll-pane",
        name = name
    }
    local flow =
        scrollpane.add {
        type = "flow",
        name = "flow",
        direction = "vertical"
    }
    make_stretchable(flow)

    tabbed_pane.add_tab(tab, scrollpane)

    return flow
end

local function get_tab_contents(tabbed_pane, name)
    return tabbed_pane[name].flow
end

local function create_separator_line(container, name)
    return container.add {
        type = "line",
        name = name or "line",
        direction = "horizontal"
    }
end

---------------------------------------------------------------------------------------------------
-- << city info gui >>
local CITY_INFO_NAME = "sosciencity-city-info"
local CITY_INFO_SPRITE_SIZE = 48

local function update_population_flow(frame)
    local population_flow = frame["general"]

    local population_count = Inhabitants.get_population_count()
    population_flow["population"].caption = {"sosciencity-gui.population", population_count}

    population_flow["machine-count"].caption = {"sosciencity-gui.machines", Register.get_machine_count()}

    population_flow["turret-count"].caption = {"sosciencity-gui.turrets", Register.get_type_count(Type.turret)}
end

local function add_population_flow(container)
    local frame =
        container.add {
        type = "frame",
        name = "general",
        direction = "vertical"
    }
    set_padding(frame, 2)

    local population_label =
        frame.add {
        type = "label",
        name = "population"
    }
    population_label.style.bottom_margin = 4

    local machine_label =
        frame.add {
        type = "label",
        name = "machine-count"
    }
    machine_label.style.bottom_margin = 4

    frame.add {
        type = "label",
        name = "turret-count"
    }

    update_population_flow(container)
end

local function add_caste_flow(container, caste_id)
    local caste_name = castes[caste_id].name

    local frame =
        container.add {
        type = "frame",
        name = "caste-" .. caste_id,
        direction = "vertical"
    }
    make_stretchable(frame)
    frame.style.padding = 0
    frame.style.left_margin = 4

    frame.visible = Inhabitants.caste_is_researched(caste_id)

    local flow =
        frame.add {
        type = "flow",
        name = "flow",
        direction = "vertical"
    }
    make_stretchable(flow)
    flow.style.vertical_spacing = 0
    flow.style.horizontal_align = "center"

    local sprite = create_caste_sprite(flow, caste_id, CITY_INFO_SPRITE_SIZE)
    sprite.style.height = CITY_INFO_SPRITE_SIZE
    sprite.style.width = CITY_INFO_SPRITE_SIZE
    sprite.style.stretch_image_to_widget_size = true
    sprite.style.horizontal_align = "center"

    flow.add {
        type = "label",
        name = "caste-population",
        caption = global.population[caste_id],
        tooltip = {"sosciencity-gui.caste-points", get_reasonable_number(effective_population[caste_id])}
    }

    flow.add {
        type = "label",
        name = "immigration",
        tooltip = {"sosciencity-gui.immigration"},
        caption = {
            "sosciencity-gui.show-immigration",
            get_reasonable_number(Inhabitants.get_immigration_trend(3600, caste_id))
        }
    }

    flow.add {
        type = "label",
        name = "caste-bonus",
        caption = {"caste-bonus.show-" .. caste_name, get_bonus_string(caste_id)},
        tooltip = {"caste-bonus." .. caste_name}
    }
end

local function update_caste_flow(container, caste_id)
    local caste_frame = container["caste-" .. caste_id]
    caste_frame.visible = Inhabitants.caste_is_researched(caste_id)

    -- the frame may not yet exist
    if caste_frame == nil then
        add_caste_flow(container, caste_id)
        return
    end

    local flow = caste_frame.flow

    local population_label = flow["caste-population"]
    population_label.caption = population[caste_id]
    population_label.tooltip = {"sosciencity-gui.caste-points", get_reasonable_number(effective_population[caste_id])}

    flow["immigration"].caption = {
        "sosciencity-gui.show-immigration",
        get_reasonable_number(Inhabitants.get_immigration_trend(3600, caste_id))
    }
    flow["caste-bonus"].caption = {
        "caste-bonus.show-" .. castes[caste_id].name,
        get_bonus_string(caste_id)
    }
end

function Gui.create_city_info_for_player(player)
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
    make_stretchable(frame)

    add_population_flow(frame)

    for id, _ in pairs(Caste.values) do
        add_caste_flow(frame, id)
    end
end

local function update_city_info(frame)
    update_population_flow(frame)

    for id, _ in pairs(Caste.values) do
        update_caste_flow(frame, id)
    end
end

function Gui.update_city_info()
    for _, player in pairs(game.players) do
        local city_info_gui = player.gui.top[CITY_INFO_NAME]

        -- we check if the gui still exists, as other mods can delete them
        if city_info_gui ~= nil and city_info_gui.valid then
            update_city_info(city_info_gui)
        else
            Gui.create_city_info_for_player(player)
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
    local flow = create_tab(tabbed_pane, "caste-chooser", {"sosciencity-gui.caste"})

    flow.style.horizontal_align = "center"
    flow.style.vertical_align = "center"
    flow.style.vertical_spacing = 6

    local at_least_one = false
    for caste_id, caste in pairs(Caste.values) do
        if Inhabitants.caste_is_researched(caste_id) then
            local caste_name = caste.name

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
            elseif castes[caste_id].required_room_count > details.room_count then
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
end

local function add_empty_house_info_tab(tabbed_pane, details)
    local flow = create_tab(tabbed_pane, "house-info", {"sosciencity-gui.building-info"})

    local data_list = create_data_list(flow, "house-infos")
    add_kv_pair(data_list, "room_count", {"sosciencity-gui.room-count"}, details.room_count)
    add_kv_pair(data_list, "comfort", {"sosciencity-gui.comfort"}, get_comfort_localised_string(details.comfort))
end

local function create_empty_housing_details(container, entry)
    set_details_view_title(container, entry[EntryKey.entity].localised_name)

    local tab_pane =
        container.add {
        type = "tabbed-pane",
        name = "tabpane"
    }

    local house_details = Housing.get(entry)
    add_caste_chooser_tab(tab_pane, house_details)
    add_empty_house_info_tab(tab_pane, house_details)
end

-- << housing details view >>
local function update_housing_general_info_tab(tabbed_pane, entry)
    local general_list = get_tab_contents(tabbed_pane, "general")["general-infos"]

    local caste = castes[entry[EntryKey.type]]
    local inhabitants = entry[EntryKey.inhabitants]
    local nominal_happiness = Inhabitants.get_nominal_happiness(entry)

    local capacity = Housing.get_capacity(entry)
    local emigration = Inhabitants.get_emigration_trend(nominal_happiness, caste, 3600) -- 3600 ticks = 1 minute
    local display_emigration = inhabitants > 0 and emigration < 0

    set_datalist_value(
        general_list,
        "capacity",
        {
            "",
            {"sosciencity-gui.show-capacity", inhabitants, capacity},
            display_emigration and {"sosciencity-gui.migration", get_migration_string(emigration)} or ""
        }
    )
    set_datalist_value_tooltip(
        general_list,
        "capacity",
        (entry[EntryKey.emigration_trend] > 0) and {"sosciencity-gui.positive-trend"} or
            {"sosciencity-gui.negative-trend"}
    )

    set_datalist_value(
        general_list,
        "happiness",
        (inhabitants > 0) and
            get_convergence_localised_string(entry[EntryKey.happiness], Inhabitants.get_nominal_happiness(entry)) or
            "-"
    )
    set_datalist_value(
        general_list,
        "health",
        (inhabitants > 0) and
            get_convergence_localised_string(entry[EntryKey.health], Inhabitants.get_nominal_health(entry)) or
            "-"
    )
    set_datalist_value(
        general_list,
        "sanity",
        (inhabitants > 0) and
            get_convergence_localised_string(entry[EntryKey.sanity], Inhabitants.get_nominal_sanity(entry)) or
            "-"
    )
    set_datalist_value(
        general_list,
        "effective-population",
        (inhabitants > 0) and
            {
                "sosciencity-gui.show-effective-population",
                get_reasonable_number(Inhabitants.get_effective_population(entry))
            } or
            "-"
    )
    set_datalist_value(
        general_list,
        "calorific-demand",
        {"sosciencity-gui.show-calorific-demand", get_reasonable_number(caste.calorific_demand * 3600 * inhabitants)}
    )
    set_datalist_value(
        general_list,
        "power-demand",
        {"sosciencity-gui.current-power-demand", caste.power_demand / 1000 * 60 * inhabitants}
    )
end

local function add_housing_general_info_tab(tabbed_pane, entry)
    local flow = create_tab(tabbed_pane, "general", {"sosciencity-gui.general"})

    flow.style.vertical_spacing = 6
    flow.style.horizontal_align = "right"

    local data_list = create_data_list(flow, "general-infos")
    add_kv_pair(data_list, "caste", {"sosciencity-gui.caste"}, get_caste_localised_string(entry[EntryKey.type]))

    add_kv_pair(data_list, "capacity", {"sosciencity-gui.capacity"})
    add_kv_pair(data_list, "happiness", {"sosciencity-gui.happiness"})
    add_kv_pair(data_list, "health", {"sosciencity-gui.health"})
    add_kv_pair(data_list, "sanity", {"sosciencity-gui.sanity"})
    add_kv_pair(data_list, "effective-population", {"sosciencity-gui.effective-population"})
    add_kv_pair(data_list, "calorific-demand", {"sosciencity-gui.calorific-demand"})
    add_kv_pair(data_list, "power-demand", {"sosciencity-gui.power-demand"})

    local kickout_button =
        flow.add {
        type = "button",
        name = Gui.UNIQUE_PREFIX .. "kickout",
        caption = {"sosciencity-gui.kickout"},
        tooltip = global.technologies.resettlement and {"sosciencity-gui.with-resettlement"} or
            {"sosciencity-gui.no-resettlement"},
        mouse_button_filter = {"left"}
    }
    kickout_button.style.right_margin = 4

    -- call the update function to set the values
    update_housing_general_info_tab(tabbed_pane, entry)
end

local function update_housing_factor_tab(tabbed_pane, entry)
    local content_flow = get_tab_contents(tabbed_pane, "details")

    local happiness_list = content_flow["happiness"]
    update_operand_entries(
        happiness_list,
        Inhabitants.get_nominal_happiness(entry),
        entry[EntryKey.happiness_summands],
        entry[EntryKey.happiness_factors]
    )

    local health_list = content_flow["health"]
    update_operand_entries(
        health_list,
        Inhabitants.get_nominal_health(entry),
        entry[EntryKey.health_summands],
        entry[EntryKey.health_factors]
    )

    local sanity_list = content_flow["sanity"]
    update_operand_entries(
        sanity_list,
        Inhabitants.get_nominal_sanity(entry),
        entry[EntryKey.sanity_summands],
        entry[EntryKey.sanity_factors]
    )
end

local function add_housing_factor_tab(tabbed_pane, entry)
    local flow = create_tab(tabbed_pane, "details", {"sosciencity-gui.details"})

    local happiness_list = create_data_list(flow, "happiness")
    create_operand_entries(
        happiness_list,
        {"sosciencity-gui.happiness"},
        "happiness-summand.",
        HappinessSummand.count,
        "happiness-factor.",
        HappinessFactor.count
    )

    create_separator_line(flow)

    local health_list = create_data_list(flow, "health")
    create_operand_entries(
        health_list,
        {"sosciencity-gui.health"},
        "health-summand.",
        HealthSummand.count,
        "health-factor.",
        HealthFactor.count
    )

    create_separator_line(flow, "line2")

    local sanity_list = create_data_list(flow, "sanity")
    create_operand_entries(
        sanity_list,
        {"sosciencity-gui.sanity"},
        "sanity-summand.",
        SanitySummand.count,
        "sanity-factor.",
        SanityFactor.count
    )

    -- call the update function to set the values
    update_housing_factor_tab(tabbed_pane, entry)
end

local function add_caste_info_tab(tabbed_pane, caste_id)
    local caste = castes[caste_id]

    local flow = create_tab(tabbed_pane, "caste", {"caste-short." .. caste.name})
    flow.style.vertical_spacing = 6
    flow.style.horizontal_align = "center"

    create_caste_sprite(flow, caste_id, 128)

    local caste_data = create_data_list(flow, "caste-infos")
    add_kv_pair(caste_data, "caste-name", {"sosciencity-gui.name"}, {"caste-name." .. caste.name})
    add_kv_pair(caste_data, "description", "", {"technology-description." .. caste.name .. "-caste"})
    add_kv_pair(
        caste_data,
        "taste",
        {"sosciencity-gui.taste"},
        {
            "sosciencity-gui.show-taste",
            {"taste-category." .. Food.taste_names[caste.favored_taste]},
            {"taste-category." .. Food.taste_names[caste.least_favored_taste]}
        }
    )
    add_kv_pair(
        caste_data,
        "food-count",
        {"sosciencity-gui.food-count"},
        {"sosciencity-gui.show-food-count", caste.minimum_food_count}
    )
    add_kv_pair(
        caste_data,
        "luxury",
        {"sosciencity-gui.luxury"},
        {"sosciencity-gui.show-luxury-needs", 100 * caste.desire_for_luxury, 100 * (1 - caste.desire_for_luxury)}
    )
    add_kv_pair(
        caste_data,
        "room-count",
        {"sosciencity-gui.room-needs"},
        {"sosciencity-gui.show-room-needs", caste.required_room_count}
    )
    add_kv_pair(
        caste_data,
        "comfort",
        {"sosciencity-gui.comfort"},
        {"sosciencity-gui.show-comfort-needs", caste.minimum_comfort}
    )
    add_kv_pair(
        caste_data,
        "power-demand",
        {"sosciencity-gui.power-demand"},
        {"sosciencity-gui.show-power-demand", caste.power_demand / 1000 * 60} -- convert from J / tick to kW
    )
end

local function update_housing_details(container, entry)
    local tabbed_pane = container.tabpane
    update_housing_general_info_tab(tabbed_pane, entry)
    update_housing_factor_tab(tabbed_pane, entry)
end

local function create_housing_details(container, entry)
    local title = {"", entry[EntryKey.entity].localised_name, "  -  ", get_caste_localised_string(entry[EntryKey.type])}
    set_details_view_title(container, title)

    local tab_pane =
        container.add {
        type = "tabbed-pane",
        name = "tabpane"
    }
    make_stretchable(tab_pane)

    add_housing_general_info_tab(tab_pane, entry)
    add_housing_factor_tab(tab_pane, entry)
    add_caste_info_tab(tab_pane, entry[EntryKey.type])
end

-- << general details view functions >>
function Gui.create_details_view_for_player(player)
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
    frame.style.width = 350
    frame.style.minimal_height = 300
    frame.style.maximal_height = 600
    frame.style.horizontally_stretchable = true
    make_squashable(frame)
    set_padding(frame, 4)

    local nested =
        frame.add {
        type = "frame",
        name = "nested",
        direction = "horizontal",
        style = "inside_deep_frame_for_tabs"
    }

    frame.visible = false
end

local function get_details_view(player)
    local details_view = player.gui.screen[DETAILS_VIEW_NAME]

    -- we check if the gui still exists, as other mods can delete them
    if details_view ~= nil and details_view.valid then
        return details_view
    else
        -- recreate it otherwise
        Gui.create_details_view_for_player(player)
        return get_details_view(player)
    end
end

local function get_nested_details_view(player)
    return get_details_view(player).nested
end

-- table with (type, update-function) pairs
local content_updaters = {
    [Type.clockwork] = update_housing_details,
    [Type.ember] = update_housing_details,
    [Type.gunfire] = update_housing_details,
    [Type.gleam] = update_housing_details,
    [Type.foundry] = update_housing_details,
    [Type.orchid] = update_housing_details,
    [Type.aurora] = update_housing_details,
    [Type.plasma] = update_housing_details
}

function Gui.update_details_view()
    local current_tick = game.tick

    for player_id, unit_number in pairs(global.details_view) do
        local entry = Register.try_get(unit_number)
        local player = game.players[player_id]

        -- check if the entity hasn't been unregistered in the meantime
        if not entry then
            Gui.close_details_view_for_player(player)
        else
            local updater = content_updaters[entry[EntryKey.type]]

            -- only update the gui if the entry got updated in this cycle
            if updater and entry[EntryKey.last_update] == current_tick then
                updater(get_nested_details_view(player), entry)
            end
        end
    end
end

-- table with (type, build-function) pairs
local detail_view_builders = {
    [Type.empty_house] = create_empty_housing_details,
    [Type.clockwork] = create_housing_details,
    [Type.ember] = create_housing_details,
    [Type.gunfire] = create_housing_details,
    [Type.gleam] = create_housing_details,
    [Type.foundry] = create_housing_details,
    [Type.orchid] = create_housing_details,
    [Type.aurora] = create_housing_details,
    [Type.plasma] = create_housing_details,
}

function Gui.open_details_view_for_player(player, unit_number)
    local entry = Register.try_get(unit_number)
    if not entry then
        return
    end

    local builder = detail_view_builders[entry[EntryKey.type]]
    if not builder then
        return
    end

    local details_view = get_details_view(player)
    local nested = details_view.nested

    nested.clear()
    builder(nested, entry)
    details_view.visible = true
    global.details_view[player.index] = unit_number
end

function Gui.close_details_view_for_player(player)
    local details_view = get_details_view(player)
    details_view.visible = false
    global.details_view[player.index] = nil
    details_view.caption = nil
    details_view.nested.clear()
end

function Gui.rebuild_details_view_for_entry(entry)
    local unit_number = entry[EntryKey.entity].unit_number

    for player_index, viewed_unit_number in pairs(global.details_view) do
        if unit_number == viewed_unit_number then
            local player = game.players[player_index]
            Gui.close_details_view_for_player(player)
            Gui.open_details_view_for_player(player, unit_number)
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

    Inhabitants.try_allow_for_caste(entry, caste_id, true)
end

function Gui.handle_kickout_button(player_index, button)
    local entry = Register.try_get(global.details_view[player_index])
    if not entry then
        return
    end

    if is_confirmed(button) then
        Register.change_type(entry, Type.empty_house)
        Gui.rebuild_details_view_for_entry(entry)
        return
    end
end

---------------------------------------------------------------------------------------------------
-- << general >>
function Gui.create_guis_for_player(player)
    Gui.create_city_info_for_player(player)
    Gui.create_details_view_for_player(player)
end

function Gui.init()
    set_locals()
    global.details_view = {}

    for _, player in pairs(game.players) do
        Gui.create_guis_for_player(player)
    end
end

function Gui.load()
    set_locals()
end

return Gui
