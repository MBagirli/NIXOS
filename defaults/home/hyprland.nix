{ osConfig, lib, pkgs, ... }:
let
  t = import ../theme.nix;
  monitors = lib.concatMapStrings (m: "monitor = ${m}\n") osConfig.my.monitors;

  workspaceBinds = lib.concatMapStrings (i:
    let n = toString i; in ''
      bind = SUPER, ${n}, workspace, ${n}
      bind = SUPER SHIFT, ${n}, movetoworkspace, ${n}
    '') (lib.range 1 9);
in
{
  # NOTE: HM's wayland.windowManager.hyprland module now emits a Lua config
  # whose API does not match the Hyprland build in nixpkgs (hl.animations is
  # nil, keys with $ or - are invalid Lua identifiers). We bypass it and
  # write the classic hyprland.conf, which Hyprland reads when no
  # hyprland.lua is present. The compositor itself comes from
  # programs.hyprland.enable at system level.

  xdg.configFile."hypr/hyprland.conf".text = ''
    ${monitors}

    $mod  = SUPER
    $term = kitty
    $menu = rofi -show drun

    exec-once = waybar
    exec-once = nm-applet --indicator
    exec-once = blueman-applet

    general {
        gaps_in = ${toString t.gaps}
        gaps_out = ${toString t.gapsOut}
        border_size = ${toString t.border}
        col.active_border = rgba(${t.accent}ee) rgba(${t.accent2}ee) 45deg
        col.inactive_border = rgba(${t.inactive}aa)
        layout = dwindle
        resize_on_border = true
    }

    decoration {
        rounding = ${toString t.rounding}
        active_opacity = 1.0
        inactive_opacity = 0.95

        blur {
            enabled = true
            size = 6
            passes = 2
        }

        shadow {
            enabled = true
            range = 12
            render_power = 3
            color = rgba(0000005a)
        }
    }

    animations {
        enabled = true
        bezier = smooth, 0.05, 0.9, 0.1, 1.0
        animation = windows, 1, 4, smooth
        animation = fade, 1, 5, default
        animation = workspaces, 1, 4, smooth, slide
    }

    dwindle {
        preserve_split = true
    }

    input {
        kb_layout = us
        follow_mouse = 1

        touchpad {
            natural_scroll = true
            disable_while_typing = true
            tap-to-click = true
        }
    }

    misc {
        disable_hyprland_logo = true
        disable_splash_rendering = true
        force_default_wallpaper = 0
        vrr = 1
    }

    bind = $mod, Return, exec, $term
    bind = $mod, D, exec, $menu
    bind = $mod, Q, killactive
    bind = $mod, E, exec, thunar
    bind = $mod, F, fullscreen
    bind = $mod, V, togglefloating
    bind = $mod, L, exec, hyprlock
    bind = $mod SHIFT, Q, exit

    bind = $mod, left, movefocus, l
    bind = $mod, right, movefocus, r
    bind = $mod, up, movefocus, u
    bind = $mod, down, movefocus, d

    bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
    bind = SHIFT, Print, exec, grim - | wl-copy

    ${workspaceBinds}

    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow

    bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
    bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    bindel = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindel = , XF86MonBrightnessUp, exec, brightnessctl s 5%+
    bindel = , XF86MonBrightnessDown, exec, brightnessctl s 5%-

    bindl = , XF86AudioPlay, exec, playerctl play-pause
    bindl = , XF86AudioNext, exec, playerctl next
    bindl = , XF86AudioPrev, exec, playerctl previous
  '';
}
