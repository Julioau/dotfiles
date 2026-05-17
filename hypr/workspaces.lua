local handle = io.popen("find ~/Archive/Moodle/ -mindepth 1 -maxdepth 1 \\( -type d -o -type l \\) | wc -l")
local count_str = handle:read("*a")
handle:close()
local permanent_ws = (tonumber(count_str) + 1) or 3

local function setup_persistent_workspaces()
    local monitors = hl.get_monitors()
    if not monitors then return end
    
    local ws_index = 1
    for _, mon in ipairs(monitors) do
        for i = 1, permanent_ws do
            hl.workspace_rule({
                workspace = tostring(ws_index),
                monitor = mon.name,
                persistent = true
            })
            ws_index = ws_index + 1
        end
    end
end

setup_persistent_workspaces()

hl.on("monitor.added", setup_persistent_workspaces)
hl.on("monitor.removed", setup_persistent_workspaces)