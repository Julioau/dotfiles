hl.config({
	general = {
		gaps_in = 2.5,
		gaps_out = 5,
		border_size = 2,
		col = {
			active_border = "rgb(a6e3a1)",
			inactive_border = "rgba(6c7a89ff)",
		},
		gaps_workspaces = -5,
		layout = "workspacelayout",
		allow_tearing = false,
		snap = {
			enabled = true,
			border_overlap = true,
			respect_gaps = true,
		},
	},
	xwayland = {
		force_zero_scaling = true,
	},
	decoration = {
		rounding = 10,
		blur = {
			enabled = true,
			contrast = 0.8,
			brightness = 0.5,
			vibrancy = 2,
			size = 16,
			passes = 4,
			xray = true,
			special = false,
		},
		dim_special = 0,
		shadow = {
			range = 0,
			render_power = 1,
			color = "rgb(a6e3a1)",
			color_inactive = "rgb(575268)",
		},
	},
	animations = {
		enabled = true,
	},
	dwindle = {
		preserve_split = true,
	},
	master = {
		mfact = 0.6,
		slave_count_for_center_master = 4,
	},
	cursor = {
		persistent_warps = true,
		inactive_timeout = 0,
	},
})

hl.curve("easeInOutCirc", { type = "bezier", points = { { 0, 0.55 }, { 0.45, 1 } } })
hl.curve("easeOutSine", { type = "bezier", points = { { 0.61, 1 }, { 0.88, 1 } } })
hl.curve("easeInOutQuint", { type = "bezier", points = { { 0.83, 0 }, { 0.17, 1 } } })
hl.curve("easeInCubic", { type = "bezier", points = { { 0.32, 0 }, { 0.67, 0 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = false, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = false, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "default", style = "slidevert" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "default", style = "slidevert" })
