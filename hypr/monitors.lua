-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = "desc: LG Display 0x06E2",
	mode = "preferred",
	position = "0x0",
	scale = "1",
})

hl.monitor({
	output = "desc: Dell Inc. DELL P2725HE DWWKG34",
	mode = "1920x1080@100",
	position = "0x-1080",
	scale = "1",
})

hl.monitor({
	output = "desc: Dell Inc. DELL P2319H 37FW923",
	mode = "preferred",
	position = "1920x-1080",
	scale = "1",
	transform = 3,
})
