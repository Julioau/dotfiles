local layouts = require("layouts")

local mod = "SUPER"

local term = "kitty"
local fileManager = "dolphin"
local web = "google-chrome-stable"
local menu = "pkill wofi || wofi -S drun -I -W 300 -p Apps -l 1 -L 14 -n -i"
local path = "/home/juli/.config/hypr"

local num_workspaces = 10

for i = 1, num_workspaces do
    local key = tostring(i)
    if i == 10 then key = "0" end
    
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = "r~" .. i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = "r~" .. i }))
end

local directions = { up = "m-1", left = "m-1", down = "m+1", right = "m+1" }

for key, target in pairs(directions) do
    hl.bind(mod .. " + CTRL + " .. key, hl.dsp.focus({ workspace = target }))
    hl.bind(mod .. " + CTRL + SHIFT + " .. key, hl.dsp.window.move({ workspace = target }))
end

hl.bind(mod .. " + SHIFT + X", hl.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "+1" }))
hl.bind(mod .. " + Z", function() layouts.cycle("next") end)
hl.bind(mod .. " + SHIFT + Z", function() layouts.cycle("prev") end)

hl.bind(mod .. " + T", hl.dsp.exec_cmd(term))
hl.bind(mod .. " + Q", hl.dsp.window.close())
-- hl.bind(mod .. " + ESCAPE", hl.dsp.exit())
hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + R", hl.dsp.exec_cmd(menu), { release = true })
hl.bind(mod .. " + P", hl.dsp.window.pin())
hl.bind(mod .. " + M", hl.dsp.window.pseudo())
hl.bind(mod .. " + W", hl.dsp.exec_cmd(web))
hl.bind(mod .. " + X", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("bluetoothctl connect 40:35:E6:2D:27:46 || notify-send 'Buds-FE' 'Connection failed.'"))
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("bluetoothctl connect E8:26:CF:90:9B:C6 || notify-send 'Dell Headset' 'Connection failed.'"))
hl.bind(mod .. " + U", hl.dsp.exec_cmd("[float; move cursor 20 20; size ] " .. term .. " -o close_on_child_death=y sh -c 'kitten unicode-input | wl-copy -n'"))
hl.bind(mod .. " + V", hl.dsp.exec_cmd("[float; move cursor 20 20; size ] " .. term .. " -o confirm_os_window_close=0 -o close_on_child_exit=yes -o allow_remote_control=yes -e bash " .. path .. "/clipfzf.sh"))
hl.bind(mod .. " + A", hl.dsp.exec_cmd("scrcpy -K || (kitty lyto && scrcpy -K)"))
hl.bind(mod .. " + SHIFT + A", hl.dsp.exec_cmd(path .. "/adbRes.sh"))
hl.bind(mod .. " + H", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind(mod .. " + D", hl.dsp.exec_cmd(path .. "/start-vpn.sh"))
hl.bind(mod .. " + K", hl.dsp.exec_cmd("kate"))
hl.bind(mod .. " + C", hl.dsp.exec_cmd("code"))
hl.bind(mod .. " + SHIFT + K", hl.dsp.exec_cmd("kile"))
hl.bind(mod .. " + O", function() layouts.cycle_orientation() end)
hl.bind(mod .. " + G", hl.dsp.group.toggle())
hl.bind(mod .. " + SHIFT + G", hl.dsp.group.lock())
hl.bind("ALT + TAB", hl.dsp.group.next())
hl.bind("ALT + SHIFT + TAB", hl.dsp.group.prev())

hl.bind("PRINT", hl.dsp.exec_cmd('hyprpicker -r -z & sleep 0.1 && grim -g "$(slurp -d)" - | wl-copy; pkill hyprpicker'))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd('hyprpicker -r -z & sleep 0.1 && grim -g "$(slurp -d)" - | tesseract stdin stdout 2>/dev/null --psm 4 | sed -E \':a;N;$!ba;s/\\n+/\\n/g\' | wl-copy; pkill hyprpicker'))
hl.bind("ALT + SHIFT + PRINT", hl.dsp.exec_cmd('hyprpicker -r -z & sleep 0.1 && grim -g "$(slurp -d)" - | tesseract stdin stdout 2>/dev/null -l por --psm 4 | sed -E \':a;N;$!ba;s/\\n+/\\n/g\' | wl-copy; pkill hyprpicker'))

hl.bind("F11", hl.dsp.window.fullscreen())
hl.bind("SHIFT + F11", hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))
hl.bind("ALT + F11", hl.dsp.window.fullscreen_state({ internal = 1, client = 1 }))

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("systemctl suspend; hyprlock"))

hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }))

hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- hl.bind(mod .. " + Up", function() hl.dispatch("pass", "Prior") end)
-- hl.bind(mod .. " + Down", function() hl.dispatch("pass", "Next") end)
-- hl.bind(mod .. " + Left", function() hl.dispatch("pass", "Home") end)
-- hl.bind("MOD2 + Right", function() hl.dispatch("pass", "End") end)

-- hl.bind("Prior", hl.dsp.exec_cmd("true"), { ignore_mods = true })
-- hl.bind("Next", hl.dsp.exec_cmd("true"), { ignore_mods = true })

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l", group = true }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r", group = true }))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u", group = true }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d", group = true }))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true })

hl.bind("SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-source-volume @DEFAULT_SINK@ +5%"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-source-volume @DEFAULT_SINK@ -5%"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { locked = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl --ignore-player=Gwenview play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl --ignore-player=Gwenview next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl --ignore-player=Gwenview previous"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl --ignore-player=Gwenview stop"), { locked = true })

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })

hl.bind("XF86Calculator", hl.dsp.exec_cmd("kcalc"))
hl.bind(mod .. " + i", hl.dsp.exec_cmd("systemctl suspend; hyprlock"))