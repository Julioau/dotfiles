-- LAN Gaming Layout for Hyprland 0.55+
-- All windows have identical dimensions in a grid.
-- Bottom row centered if incomplete.
-- Options: fixed_ratio (float)

hl.layout.register("lan", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 then return end

        local area = ctx.area
        local gaps_in = hl.get_config("general.gaps_in")
        -- In Hyprland, the gap between two windows is gaps_in * 2
        local m = (gaps_in.top or 0) * 2

        -- Check for layout options
        local fixed_ratio = 0
        if ctx.layout_opts and ctx.layout_opts.fixed_ratio then
            fixed_ratio = tonumber(ctx.layout_opts.fixed_ratio) or 0
        end

        local best_rows = 1
        local best_cols = n
        local best_w = 0
        local best_h = 0
        local best_penalty = math.huge
        local best_area = -1

        for rows = 1, n do
            local cols = math.ceil(n / rows)
            
            -- avail space subtracting gaps between items
            local avail_w = area.width - (cols - 1) * m
            local avail_h = area.height - (rows - 1) * m

            local w, h
            if fixed_ratio > 0 then
                h = math.min(avail_w / (cols * fixed_ratio), avail_h / rows)
                w = h * fixed_ratio
                local current_area = w * h
                if current_area > best_area then
                    best_area = current_area
                    best_rows = rows
                    best_cols = cols
                    best_w = w
                    best_h = h
                end
            else
                w = avail_w / cols
                h = avail_h / rows
                local penalty = math.max(w / h, h / w)
                if penalty < best_penalty then
                    best_penalty = penalty
                    best_rows = rows
                    best_cols = cols
                    best_w = w
                    best_h = h
                end
            end
        end

        local rows = best_rows
        local cols = best_cols
        local w = best_w
        local h = best_h

        -- Placement logic
        for i, target in ipairs(ctx.targets) do
            local r_idx = math.floor((i - 1) / cols)
            local c_idx = (i - 1) % cols

            local x_offset = 0
            local items_in_this_row = cols
            if r_idx == rows - 1 then
                items_in_this_row = n - (rows - 1) * cols
            end

            if items_in_this_row < cols then
                local used_width = (items_in_this_row * w) + ((items_in_this_row - 1) * m)
                x_offset = (area.width - used_width) / 2
            end

            local x = area.x + x_offset + (c_idx * (w + m))
            local y = area.y + (r_idx * (h + m))

            target:place({
                x = x,
                y = y,
                width = w,
                height = h
            })
        end
    end,
})
