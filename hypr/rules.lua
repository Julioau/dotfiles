hl.window_rule({
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	match = { class = "xdg-desktop-portal-gtk" },
	float = true,
})

hl.window_rule({
	match = { class = "org.kde.kalk" },
	float = true,
})

hl.window_rule({
	match = { title = "KCalc" },
	float = true,
})

hl.window_rule({
	match = { title = ".*is sharing (a window|your screen)." },
	opacity = "0.0 override 1",
	no_anim = true,
	no_focus = true,
	decorate = true,
})

hl.window_rule({
	match = { title = "Can't update Chrome" },
	float = true,
})

hl.window_rule({
	match = { class = "scrcpy" },
	size = "1080 2400",
	pseudo = true,
	keep_aspect_ratio = true,
})

hl.window_rule({
	match = { title = "Picture in picture" },
	keep_aspect_ratio = true,
	pin = true,
})

local menu = "pkill wofi || wofi -S drun -I -W 300 -p Apps -l 1 -L 14 -n -i"
hl.window_rule({
	match = { title = menu },
	no_anim = true,
})

hl.window_rule({
	match = { title = "zoom" },
	opacity = "0.0",
	no_initial_focus = true,
})

-- Workspace rules
-- hl.window_rule({
-- 	match = { initial_title = "^(YouTube Music)$" },
-- 	workspace = "special:magic silent",
-- })
--
-- hl.window_rule({
-- 	match = { initial_title = "^(web.whatsapp.com)$" },
-- 	workspace = "special:magic",
-- })
--
-- hl.window_rule({
-- 	match = { initial_title = "^(discord.com_/channels/@me)$" },
-- 	workspace = "special:magic",
-- })

-- Route social app classes to the special:social workspace
local social_classes = { "whatsapp", "discord", "teams", "outlook" }
for _, class in ipairs(social_classes) do
    hl.window_rule({
        match = { class = ".*" .. class .. ".*" },
        workspace = "special:social"
    })
end

