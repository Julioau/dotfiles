hl.config({
    input = {
        repeat_delay = 250,
        repeat_rate = 50,
        follow_mouse = 1,
        scroll_button_lock = false,
        scroll_method = "on_button_down",
        scroll_button = 274,
        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = true,
            disable_while_typing = false,
        },
        sensitivity = 0,
    }
})

hl.device({
    name = "dell-computer-corp-dell-universal-receiver",
    kb_layout = "br"
})

hl.device({
    name = "gsr-ui-virtual-keyboard",
    kb_model = "inspiron",
    kb_layout = "br"
})

hl.device({
    name = "at-translated-set-2-keyboard",
    kb_model = "inspiron",
    kb_layout = "br"
})
