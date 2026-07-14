-- LAN Gaming Layout for Hyprland 0.55+
-- All windows have identical dimensions in a grid.
-- Bottom row centered if incomplete.

hl.layout.register("lan", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 or not ctx.area then return end
        
        local area = ctx.area
        local aw = area.width or area.w or 0
        local ah = area.height or area.h or 0
        local ax = area.x or 0
        local ay = area.y or 0

        if aw == 0 or ah == 0 then return end
        
        local gaps_in = hl.get_config("general.gaps_in")
        local gi = 0
        if type(gaps_in) == "table" then
            gi = gaps_in.top or 0
        elseif type(gaps_in) == "number" then
            gi = gaps_in
        end
        local m = gi * 2

        -- Optimization for squareness
        local best_rows = 1
        local best_penalty = 1e18
        
        for r = 1, n do
            local c = math.ceil(n / r)
            local w_cand = (aw - (c - 1) * m) / c
            local h_cand = (ah - (r - 1) * m) / r
            
            if w_cand > 0 and h_cand > 0 then
                local penalty = math.max(w_cand / h_cand, h_cand / w_cand)
                if penalty < best_penalty then
                    best_penalty = penalty
                    best_rows = r
                end
            end
        end
        
        local rows = best_rows
        local cols = math.ceil(n / rows)
        
        -- Final cell dimensions
        local w = math.floor((aw - (cols - 1) * m) / cols)
        local h = math.floor((ah - (rows - 1) * m) / rows)

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
                x_offset = math.floor((aw - used_width) / 2)
            end

            target:place({
                x = ax + x_offset + (c_idx * (w + m)),
                y = ay + (r_idx * (h + m)),
                w = w,
                h = h
            })
        end
    end,
})
