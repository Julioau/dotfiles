-- Test script for LAN layout logic
-- Mocking Hyprland API

local hl = {
    layout = {
        register = function(name, tbl)
            _G.lan_layout = tbl
        end
    },
    get_config = function(name)
        if name == "general.gaps_in" then
            return { top = 5, left = 5, right = 5, bottom = 5 }
        end
        return {}
    end
}

_G.hl = hl

-- Load the layout
local f = loadfile("/home/juli/Archive/Customizations/dotfiles/hypr/lan.lua")
f()

local function test_layout(n, fixed_ratio)
    print(string.format("\n--- Testing N=%d, fixed_ratio=%s ---", n, tostring(fixed_ratio)))
    
    local targets = {}
    for i = 1, n do
        table.insert(targets, {
            index = i,
            place = function(self, box)
                -- print(string.format("Window %d: x=%.2f, y=%.2f, w=%.2f, h=%.2f", i, box.x, box.y, box.width, box.height))
                self.box = box
            end
        })
    end

    local area = { x = 0, y = 0, width = 1920, height = 1080 }
    local ctx = {
        targets = targets,
        area = area,
        layout_opts = { fixed_ratio = fixed_ratio }
    }

    _G.lan_layout.recalculate(ctx)

    -- Verification 1: Identical dimensions
    local w1, h1 = targets[1].box.width, targets[1].box.height
    for i = 1, n do
        local box = targets[i].box
        if math.abs(box.width - w1) > 0.01 or math.abs(box.height - h1) > 0.01 then
            print(string.format("FAILURE: Window %d has different dimensions! (%.2f x %.2f vs %.2f x %.2f)", i, box.width, box.height, w1, h1))
            return false
        end
    end
    print("Verification: Identical dimensions -> PASS")

    -- Verification 2: Bottom row centering
    -- Find indices of windows in the last row
    local last_row_indices = {}
    local max_y = 0
    for i=1, n do max_y = math.max(max_y, targets[i].box.y) end
    for i=1, n do
        if math.abs(targets[i].box.y - max_y) < 0.1 then
            table.insert(last_row_indices, i)
        end
    end

    local items_in_last = #last_row_indices
    local row_width = (items_in_last * w1) + (items_in_last - 1) * 5
    local expected_x_offset = (area.width - row_width) / 2
    local actual_x_offset = targets[last_row_indices[1]].box.x - area.x

    if math.abs(actual_x_offset - expected_x_offset) > 0.1 then
        print(string.format("FAILURE: Bottom row NOT centered! Expected offset %.2f, got %.2f", expected_x_offset, actual_x_offset))
        return false
    end
    print(string.format("Verification: Bottom row centering (%d items) -> PASS", items_in_last))

    return true
end

-- Test cases
local success = true
success = success and test_layout(1)
success = success and test_layout(2)
success = success and test_layout(3)
success = success and test_layout(4)
success = success and test_layout(10) -- 10 items, 4 cols -> 2 items in last row
success = success and test_layout(5, 1.0) -- 5 items, square -> 3 cols? last row 2 items.

if success then
    print("\nALL TESTS PASSED")
else
    print("\nSOME TESTS FAILED")
    os.exit(1)
end
