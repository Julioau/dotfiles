hl.config({
    dwindle = {
        force_split = 0,
        preserve_split = false,
        smart_split = false,
        smart_resizing = true,
        permanent_direction_override = false,
        special_scale_factor = 1,
        split_width_multiplier = 1.0,
        use_active_for_splits = true,
        default_split_ratio = 1.0,
        split_bias = 0,
        precise_mouse_move = false,
    },
    master = {
        allow_small_split = false,
        special_scale_factor = 1,
        mfact = 0.55,
        new_status = "slave",
        new_on_top = false,
        new_on_active = "none",
        orientation = "left",
        slave_count_for_center_master = 2,
        center_master_fallback = "left",
        smart_resizing = true,
        drop_at_cursor = true,
        always_keep_position = false,
    },
    scrolling = {
        fullscreen_on_one_column = true,
        column_width = 0.5,
        focus_fit_method = 1,
        follow_focus = true,
        follow_min_visible = 0.4,
        explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
        wrap_focus = true,
        wrap_swapcol = true,
        direction = "right",
    },
})

local layouts = { "dwindle", "master", "scrolling", "monocle", "lua:lan" }
local orientations = { "left", "top", "right", "bottom", "center" }

-- Initialize state
local current_layout = hl.get_config("general:layout") or "dwindle"
local current_orient_idx = 1
local initial_orient = hl.get_config("master:orientation") or "left"

for i, o in ipairs(orientations) do
    if o == initial_orient then
        current_orient_idx = i
        break
    end
end

local function cycle_layout(direction)
    local ws = hl.get_active_workspace()
    if not ws then return end

    local idx = 1
    for i, l in ipairs(layouts) do
        if l == current_layout then
            idx = i
            break
        end
    end

    if direction == "prev" then
        idx = idx - 1
        if idx < 1 then idx = #layouts end
    else
        idx = idx + 1
        if idx > #layouts then idx = 1 end
    end

    current_layout = layouts[idx]
    
    -- Execute layout change
    hl.workspace_rule({
        workspace = tostring(ws.id),
        layout = current_layout
    })

    local notify_text = "Layout: " .. current_layout
    if current_layout == "master" then
        notify_text = notify_text .. "\nOrientation: " .. orientations[current_orient_idx]
    end

    hl.notification.create({
        text = notify_text,
        timeout = 1500
    })
end

local function orientation_cycle()
    if current_layout ~= "master" then
        hl.notification.create({
            text = "Orientation cycle only works in Master layout",
            timeout = 1500
        })
        return
    end

    -- Execute the actual rotation
    hl.dispatch(hl.dsp.layout("orientationnext"))

    -- Sync state for notification
    current_orient_idx = current_orient_idx % #orientations + 1
    local next_orient = orientations[current_orient_idx]

    hl.notification.create({
        text = "Orientation: " .. next_orient,
        timeout = 1000
    })
end

return {
    cycle = cycle_layout,
    cycle_orientation = orientation_cycle
}
