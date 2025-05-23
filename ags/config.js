import { applauncher } from "./applauncher.js"
const hyprland = await Service.import("hyprland")
const notifications = await Service.import("notifications")
const mpris = await Service.import("mpris")
const audio = await Service.import("audio")
const battery = await Service.import("battery")
const systemtray = await Service.import("systemtray")
const powerProfiles = await Service.import('powerprofiles')
const dispatch = ws => hyprland.messageAsync(`dispatch workspace ${ws}`);

const date = Variable("", {
    poll: [60000, 'date "+%H:%M %b %e"'],
})

// widgets can be only assigned as a child in one container
// so to make a reuseable widget, make it a function
// then you can simply instantiate one by calling it

function Workspaces() {
  const activeId = hyprland.active.workspace.bind("id");
  const workspaces = hyprland.bind("workspaces").as((ws) =>
    ws
      // remove scratchpads from the list
      .filter(({ id }) => id > 0)
      // sort by id
      .sort((a, b) => a.id - b.id)
      .map(({ id }) =>
        Widget.Button({
          on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
          child: Widget.Label(`${id}`),
          class_name: activeId.as((i) => `${i === id ? "focused" : ""}`),
        })
      )
  );

  return Widget.Box({
    class_name: "workspaces",
    children: workspaces,
  });
}


// const Workspaces = () => Widget.EventBox({
//     // const activeId = hyprland.active.workspace.bind("id"),
//     onScrollUp: () => dispatch('+1'),
//     onScrollDown: () => dispatch('-1'),
//     child: Widget.Box({
//         children: Array.from({ length: 10 }, (_, i) => i + 1).map(i => Widget.Button({
//             attribute: i,
//             label: `${i}`,
//             onClicked: () => dispatch(i),
//             css: "padding-left: 5px",
//         })),
// 
//         // remove this setup hook if you want fixed number of buttons
//         setup: self => self.hook(hyprland, () => self.children.forEach(btn => {
//             btn.visible = hyprland.workspaces.some(ws => ws.id === btn.attribute);
//         })),
//     }),
// })


function ClientTitle() {
    return Widget.Label({
        class_name: "client-title",
        label: hyprland.active.client.bind("title"),
    })
}


function Clock() {
    return Widget.Label({
        class_name: "clock",
        css: "min-width: 100px", 
        // css: "padding-right: 20px",
        label: date.bind(),
    })
}


// we don't need dunst or any other notification daemon
// because the Notifications module is a notification daemon itself
function Notification() {
    const popups = notifications.bind("popups")
    return Widget.Box({
        class_name: "notification",
        visible: popups.as(p => p.length > 0),
                      children: [
                          Widget.Icon({
                              icon: "preferences-system-notifications-symbolic",
                          }),
                      Widget.Label({
                          label: popups.as(p => p[0]?.summary || ""),
                      }),
                      ],
    })
}

function Volume() {
    const icons = {
        101: "overamplified",
        67: "high",
        34: "medium",
        1: "low",
        0: "muted",
    }

    function getIcon() {
        const icon = audio.speaker.is_muted ? 0 : [101, 67, 34, 1, 0].find(
            threshold => threshold <= audio.speaker.volume * 100)

        return `audio-volume-${icons[icon]}-symbolic`
    }

    const icon = Widget.Icon({
        icon: Utils.watch(getIcon(), audio.speaker, getIcon),
    })

    // const slider = Widget.Slider({
    //     hexpand: true,
    //     draw_value: true,
    //     on_change: ({ value }) => audio.speaker.volume = value,
    //                              setup: self => self.hook(audio.speaker, () => {
    //                                  self.value = audio.speaker.volume || 0
    //                              }),
    // })

    return Widget.Box({
        class_name: "volume",
        // css: "min-width: 180px",
        children: [icon/*, slider*/],
    })
}

function Media() {
    const label = Utils.watch("", mpris, "player-changed", () => {
        if (mpris.players[0]) {
            const { track_artists, track_title } = mpris.players[0]
            return `${track_artists.join(", ")} - ${track_title}`
        } else {
            return "Nothing is playing"
        }
    })

    return Widget.Button({
        class_name: "media",
        on_primary_click: () => mpris.getPlayer("")?.playPause(),
                         on_scroll_up: () => mpris.getPlayer("")?.next(),
                         on_scroll_down: () => mpris.getPlayer("")?.previous(),
                         child: Widget.Label({ label }),
    })
}



function BatteryLabel() {
    const value = battery.bind("percent").as(p => p > 0 ? p / 100 : 0)
    const icon = battery.bind("percent").as(p =>
    `battery-level-${Math.floor(p / 10) * 10}-symbolic`)

    return Widget.Box({
        class_name: "battery",
        visible: battery.bind("available"),
                      children: [
                          Widget.Icon({ icon }),
                      Widget.LevelBar({
                          widthRequest: 140,
                          vpack: "center",
                          value,
                      }),
                      ],
    })
}

const label = Widget.Label({
    label: powerProfiles.bind('active_profile'),
})

const button = Widget.Button({
    on_clicked: () => {
        switch (powerProfiles.active_profile) {
            case 'balanced':
                powerProfiles.active_profile = 'performance';
                break;
            case 'performance':
                powerprofiles.active_profile = 'power-saver'
            case 'power-saver':
                powerProfiles.active_profile = 'balanced';
                break;
        };
    },
})

function SysTray() {
    const items = systemtray.bind("items")
    .as(items => items.map(item => Widget.Button({
        child: Widget.Icon({ icon: item.bind("icon") }),
            on_primary_click: (_, event) => item.activate(event),
            on_secondary_click: (_, event) => item.openMenu(event),
            tooltip_markup: item.bind("tooltip_markup"),
    })))

    return Widget.Box({
        children: items,
    })
}


// layout of the bar
function Left() {
    return Widget.Box({
        spacing: 5,
        children: [
            Workspaces(),

        ],
    })
}

function Center() {
    return Widget.Box({
        spacing: 8,
        children: [
            ClientTitle(),
            Notification(),
        ],
    })
}

function Right() {
    return Widget.Box({
        hpack: "end",
        spacing: 20,
        children: [
            SysTray(),
            Media(),
            Volume(),
            BatteryLabel(),
            Clock(),
        ],
    })
}

function Bar(monitor = 0) {
    return Widget.Window({
        name: `bar-${monitor}`, // name has to be unique
        class_name: "bar",
        monitor,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            start_widget: Left(),
            center_widget: Center(),
            end_widget: Right(),
        }),
    })
}

App.config({
    style: "./style.css",
    windows: [
        Bar(0),
        // you can call it, for each monitor
        // Bar(1),
        applauncher
    ],
})

export { }
