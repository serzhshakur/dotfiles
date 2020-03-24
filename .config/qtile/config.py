from libqtile.config import Key, ScratchPad, DropDown, Screen, Group, Drag, Click, Match
from libqtile.command import lazy
from libqtile import layout, bar, widget, hook

from typing import List  # noqa: F401
import os
import subprocess


mod = "mod4"

keys = [
    # Switch between windows in current stack pane
    Key([mod], "k", lazy.layout.down()),
    Key([mod], "j", lazy.layout.up()),
    Key([mod], "h", lazy.layout.left()),
    Key([mod], "l", lazy.layout.right()),
    Key([mod], "Up", lazy.layout.increase_ratio(), lazy.layout.grow(),),
    Key([mod], "Down", lazy.layout.decrease_ratio(), lazy.layout.shrink(),),
    Key([mod], "n", lazy.layout.normalize(),),      # in Monadtall mode
    Key([mod], "Right", lazy.layout.grow_main(),),  # in Monadtall mode
    Key([mod], "Left", lazy.layout.shrink_main(),), # in Monadtall mode

    # Move windows up or down in current stack
    Key([mod, "control"], "k", lazy.layout.shuffle_down()),
    Key([mod, "control"], "j", lazy.layout.shuffle_up()),

    # Switch window focus to other pane(s) of stack
    Key([mod], "space", lazy.layout.next()),

    # Swap panes of split stack
    Key([mod, "shift"], "space", lazy.layout.rotate(), lazy.layout.flip(),),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split()),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout()),
    Key([mod], "w", lazy.window.kill()),

    Key([mod, "control"], "r", lazy.restart()),
    Key([mod, "control"], "q", lazy.shutdown()),
    Key([mod], "r", lazy.spawncmd()),
    
    # Apps
      
    Key([mod], "Return", lazy.spawn("alacritty")),
    Key([mod], "grave", lazy.spawn("rofi -show")), # grave=backtick
    Key(["control", "shift"], "p", lazy.spawn("flameshot gui")),

    # Light locker
    Key([mod], "l", lazy.spawn("light-locker-command -l")),

    # Brightness
    Key([], 'XF86MonBrightnessUp',   lazy.spawn("light -A 10")),
    Key([], 'XF86MonBrightnessDown', lazy.spawn("light -U 10")),

    # Audio
    Key([], 'XF86AudioRaiseVolume', lazy.spawn('pactl -- set-sink-volume 0 +5%')),
    Key([], 'XF86AudioLowerVolume', lazy.spawn('pactl -- set-sink-volume 0 -5%')),

]

cols = {
    "bg": "#4C5760",
    "bg_dark": "#1C2023",
    "fg": "#FFFBFC",
    "fg_inactive": "#93A8AC"
}

layout_theme = {
    "border_width": 3,
    "margin": 3,
    "border_focus": "a8a897",
    "border_normal": "#555555"
}

treetab_theme = {
    "fontsize": 12,
    "panel_width": 220,
    "bg_color": "#3B4349",
    "active_bg": cols["bg_dark"],
    "active_fg": cols["fg"],
    "inactive_bg": "#3B4349",
    "inactive_fg": cols["fg_inactive"],
    "padding_x": 5,
    "padding_y": 10,
    "margin_left": 0,
    "margin_y": 5,    
}

layouts = [
    layout.Max(),
    layout.Stack(num_stacks=2, **layout_theme),
    layout.Tile(shift_windows=True, **layout_theme)
]

class GroupConfig:
  def __init__(self, name, label, matches=None, spawn=None, group_layouts=layouts):
    self.name = name
    self.label = label
    self.matches = matches
    self.spawn = spawn
    self.group_layouts = group_layouts

# use xprop to detect WM_CLASS for a window
groups_config = [
   GroupConfig(
        'a', 
        '', 
        [ Match(wm_class=["Firefox", "Google-chrome", "Chromium", "Vivaldi-stable", "Brave"], role=["browser"]) ],
        spawn='vivaldi-stable',
        group_layouts=[
           layout.Max(), 
           layout.TreeTab(**layout_theme, **treetab_theme)
        ]
   ),
   GroupConfig(
        's', 
        '', 
        [ Match(wm_class=["UXTerm", "URxvt", "Urxvt-tabbed", "Urxvt", "XTerm", "Termite", "alacritty", "Lxterminal"]) ],
        spawn='alacritty',
        group_layouts=[layout.MonadTall(**layout_theme)]
   ),
   GroupConfig(
        'd', 
        '',
        [ Match(wm_class=["jetbrains-idea", "code", "Code"]) ],
        group_layouts=[
           layout.Max(), 
           layout.TreeTab(**treetab_theme, **layout_theme)
        ]
   ),
   GroupConfig(
        'f', 
        '', 
        [ Match(wm_class=[ "Pcmanfm", "Thunar", "dolphin" ]) ],
   ),
   GroupConfig(
        'u', 
        '', 
        [ Match(wm_class=[ "rambox", "Rambox" ]) ],
   ),
   GroupConfig(
        'i', 
        '', 
        [ Match(wm_class=[ "spotify", "Spotify" ]) ],
   ),
   GroupConfig(
        'o', 
        '', 
        group_layouts=[
           layout.Max(),
           layout.TreeTab(**treetab_theme, **layout_theme)
        ]
   ),
]

groups = [ 
    Group(
         name=config.name,
         label=config.label,
         matches=config.matches,
         spawn=config.spawn,
         layouts=config.group_layouts
    ) 
    for config in groups_config 
   ]

groups.append(
    ScratchPad("x", [
        DropDown("term", "alacritty", height=0.7, width=1, x=0) 
    ])
)

for i in groups:
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod], i.name, lazy.group[i.name].toscreen()),

        # mod1 + shift + letter of group = switch to & move focused window to group
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name)),
    ])

# Key bindings for scratchpads
keys.append(
    Key([], 'F1', lazy.group["x"].dropdown_toggle("term")),
)

widget_defaults = dict(
    font='Droid Sans',
    fontsize=16,
    padding=3,
)
extension_defaults = widget_defaults.copy()

def get_kb_layout():
    output = subprocess.run(['xkblayout-state', 'print', '%s'], capture_output=True, encoding="utf-8").stdout
    return output

screens = [
    Screen(
        top=bar.Bar(
            [
              widget.Sep(
                        linewidth = 0,
                        padding = 6,
                        ),
               widget.GroupBox(
                        font="font-awesome",
                        margin_y = 0,
                        margin_x = 0,
                        padding_y = 7,
                        padding_x = 7,
                        borderwidth = 3,
                        active = cols['fg'],
                        inactive = cols['fg_inactive'],
                        rounded = False,
                        highlight_method = "block",
                        this_current_screen_border = cols['bg_dark'],
                        ),
              widget.Sep(
                        linewidth = 0,
                        padding = 10,
                        ),
               widget.CurrentLayoutIcon(
                        scale=0.9
                        ),
               widget.CurrentLayout(
                        padding = 5
                        ),
               widget.Sep(
                        linewidth = 0,
                        padding = 10,
                        ),
               widget.WindowName(
                        font="Ubuntu",
                        padding = 7,
                        fontsize = 12,
                        foreground = cols['fg_inactive'],
                        ),
               widget.Sep(
                        linewidth = 0,
                        padding = 10,
                        ),
                widget.Mpris2(
                        name='spotify',
                        scroll_chars=None,
                        display_metadata=['xesam:title', 'xesam:artist'],
                        objname="org.mpris.MediaPlayer2.spotify",
			stop_pause_text='',
			padding=10
                        ),
               widget.TextBox(
                        text="cpu:",
                        padding = 5,
                        fontsize=12
                        ),
                widget.CPUGraph(
                        type="box",
                        margin_y = 2,
                        border_width=1,
                        border_color=cols['fg_inactive'],
                        line_width=2
                        ),
               widget.TextBox(
                        text="mem:",
                        padding = 5,
                        fontsize=12
                        ),
                widget.MemoryGraph(
                        type="box",
                        margin_y = 2,
                        border_width=1,
                        border_color=cols['fg_inactive'],
                        line_width=2
                        ),
               widget.Spacer(length=30),
               widget.BatteryIcon(
			padding = 0,
			margin = 0
	       ),
               widget.Battery(
			padding = 0,
                        charge_char = "↑ ",
                        discharge_char = "↓ ",
			unknown_char = '',
                        format = '{char}{percent:2.0%}',
                        ),
               widget.Spacer(length=15),
               widget.TextBox(
                        font="font-awesome",
                        text="",
                        padding = 0,
                        fontsize=15,
                        ),
               widget.Backlight(
                        brightness_file='/sys/class/backlight/intel_backlight/brightness',
                        max_brightness_file='/sys/class/backlight/intel_backlight/max_brightness',
			change_command='light -S {0}'
                        ),
               widget.Spacer(length=12),
               widget.TextBox(
                        font="font-awesome",
                        text="⟳",
                        fontsize=20,
                        ),
               widget.Pacman(
                        command='alacritty',
                        ),
         #      widget.Spacer(length=15),
         #      widget.TextBox(
         #               font="font-awesome",
         #               text=" ",
         #               padding = 0,
         #               fontsize=14
         #               ),
         #      widget.Volume(),
         #      widget.TextBox(
         #               font="font-awesome",
         #               text="",
         #               fontsize=15,
         #               padding=3,
         #      ),
         #      widget.DF(
         #               visible_on_warn=True
         #               ),
               widget.Sep(
                        linewidth=1,
			padding=20
               ),
               widget.Systray(
	                padding = 10,
			icon_size = 23,
			),
               widget.Sep(
                        linewidth = 1,
                        padding = 30
               ),
	       widget.GenPollText(
	                func=get_kb_layout,
			update_interval=0.5,
                        font='Droid Sans, Bold',
			width=25
			),
               widget.Sep(
                        linewidth=1,
                        padding=10
               ),
               widget.Clock(
                        format="%a, %b %d"
                        ),
               widget.Sep(
                        linewidth=1,
                        padding=10
               ),
               widget.Clock(
                        fontsize=17,
                        font='Droid Sans, Bold',
                        format="%H:%M"
                        ),
               widget.Sep(
                        linewidth = 1,
                        padding = 5,
                        ),
            ],
            size=30,
            background = cols['bg'],
            foreground = cols['fg'],
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(border_width=0, float_rules=[
    {'wmclass': 'confirm'},
    {'wmclass': 'dialog'},
    {'wmclass': 'download'},
    {'wmclass': 'error'},
    {'wmclass': 'file_progress'},
    {'wmclass': 'notification'},
    {'wmclass': 'splash'},
    {'wmclass': 'toolbar'},
    {'wmclass': 'confirmreset'},  # gitk
    {'wmclass': 'makebranch'},  # gitk
    {'wmclass': 'maketag'},  # gitk
    {'wname': 'branchdialog'},  # gitk
    {'wname': 'pinentry'},  # GPG key password entry
    {'wmclass': 'ssh-askpass'},  # ssh-askpass
])

# Autostart

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/autostart.sh'])

auto_fullscreen = True
focus_on_window_activation = "smart"

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
