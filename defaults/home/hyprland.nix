{ osConfig, config, lib, pkgs, ... }:
let
  t = import ../theme.nix;
  monitors = lib.concatMapStrings (m: "monitor = ${m}\n") osConfig.my.monitors;

  # Workspace switch + move-window, 1..9
  workspaceBinds = lib.concatMapStrings (i:
    let n = toString i; in ''
      bind = SUPER, ${n}, workspace, ${n}
      bind = SUPER SHIFT, ${n}, movetoworkspacesilent, ${n}
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
    # Monitors live in a separate MUTABLE file so nwg-displays can write
    # to them. Seeded once from hosts/rog/default.nix (my.monitors) by the
    # activation script below, then owned by the user — same pattern as
    # the wallpaper.
    source = ~/.config/hypr/monitors.conf

    $mod     = SUPER
    $term    = kitty
    $menu    = rofi -show drun
    $browser = firefox
    $files   = thunar

    exec-once = waybar

    general {
        gaps_in = ${toString t.gaps}
        gaps_out = ${toString t.gapsOut}
        border_size = ${toString t.border}
        col.active_border = rgba(${t.accent}ee) rgba(${t.accent2}ee) 45deg
        col.inactive_border = rgba(${t.inactive}aa)
        layout = dwindle
        resize_on_border = true
        extend_border_grab_area = 8
        hover_icon_on_border = true

        snap {
            enabled = true
        }
    }

    decoration {
        rounding = ${toString t.rounding}
        active_opacity = 1.0
        inactive_opacity = 0.95

        blur {
            enabled = true
            size = 6
            passes = 2
            new_optimizations = true
            xray = false
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
        bezier = snappy, 0.2, 1.0, 0.3, 1.0
        animation = windows, 1, 4, smooth
        animation = windowsOut, 1, 4, smooth, popin 80%
        animation = fade, 1, 5, default
        animation = border, 1, 8, default
        animation = workspaces, 1, 4, snappy, slide
        animation = layers, 1, 3, snappy, fade
    }

    dwindle {
        preserve_split = true
        smart_split = false
        smart_resizing = true
    }

    input {
        kb_layout = us
        follow_mouse = 1
        # focus follows the mouse but does not raise floating windows —
        # stops accidental focus steals when the pointer crosses a dialog
        float_switch_override_focus = 0

        touchpad {
            natural_scroll = true
            disable_while_typing = true
            tap-to-click = true
            scroll_factor = 0.6
        }
    }

    # Software cursors avoid the flicker / disappearing pointer that the
    # NVIDIA driver causes with hardware cursor planes on hybrid laptops.
    cursor {
        no_hardware_cursors = true
        inactive_timeout = 5
    }

    binds {
        # pressing the current workspace's key again returns to the previous
        workspace_back_and_forth = true
        allow_workspace_cycles = true
    }

    misc {
        disable_hyprland_logo = true
        disable_splash_rendering = true
        force_default_wallpaper = 0
        vrr = 1
        focus_on_activate = true
        # a lone window gets no gaps and no border — less visual noise
        # when a terminal is the only thing on a workspace
        # (comment out if you prefer constant framing)
        # no_gaps_when_only = 1
    }

    ecosystem {
        no_update_news = true
        no_donation_nag = true
    }

    xwayland {
        force_zero_scaling = true
    }

    # ---- window rules ----
    # REMOVED. This Hyprland build rejects both spellings:
    #   windowrule   = float, class:^(pavucontrol)$  -> "invalid field float"
    #   windowrulev2 = float, class:^(pavucontrol)$  -> "windowrulev2 is deprecated"
    # which means it wants `windowrule` with a different matcher syntax.
    # Run `hyprctl descriptions | grep -A3 -i windowrule` to see the form
    # this version documents, then add rules back one at a time and check
    # with `hyprctl configerrors`.

    # NOTE: no layerrule lines. The `layerrule = blur, rofi` syntax that
    # blurs overlay backgrounds is rejected by this Hyprland version
    # ("invalid field blur: missing a value"). The rofi themes are already
    # translucent, so the loss is cosmetic. Check
    # `hyprctl descriptions | grep -i layerrule` before adding it back.

    # ---- launch ----
    bind = $mod, Return, exec, $term
    bind = $mod, D, exec, $menu
    bind = $mod, B, exec, $browser
    bind = $mod SHIFT, B, exec, $browser -P work
    bind = $mod, E, exec, $files
    bind = $mod, K, exec, hypr-keys
    bind = $mod, P, exec, nwg-displays
    bind = $mod, W, exec, wallpaper-picker
    bind = $mod SHIFT, W, exec, sddm-wallpaper-picker
    bind = $mod, L, exec, hyprlock
    bind = $mod SHIFT, E, exec, power-menu
    bind = $mod SHIFT, S, exec, screenshot

    # ---- window management ----
    bind = $mod, Q, killactive
    bind = $mod, F, fullscreen, 0
    bind = $mod SHIFT, F, fullscreen, 1        # maximise within gaps
    bind = $mod, V, togglefloating
    bind = $mod, C, centerwindow
    bind = $mod SHIFT, Q, exit

    # focus
    bind = $mod, left,  movefocus, l
    bind = $mod, right, movefocus, r
    bind = $mod, up,    movefocus, u
    bind = $mod, down,  movefocus, d
    bind = $mod, Tab,   cyclenext
    bind = $mod SHIFT, Tab, cyclenext, prev

    # move window
    bind = $mod SHIFT, left,  movewindow, l
    bind = $mod SHIFT, right, movewindow, r
    bind = $mod SHIFT, up,    movewindow, u
    bind = $mod SHIFT, down,  movewindow, d

    # resize, held
    binde = $mod CTRL, left,  resizeactive, -40 0
    binde = $mod CTRL, right, resizeactive, 40 0
    binde = $mod CTRL, up,    resizeactive, 0 -40
    binde = $mod CTRL, down,  resizeactive, 0 40

    # ---- workspaces ----
    ${workspaceBinds}

    bind = $mod, mouse_down, workspace, e+1
    bind = $mod, mouse_up,   workspace, e-1
    bind = $mod CTRL, right, workspace, e+1
    bind = $mod CTRL, left,  workspace, e-1

    # move the focused window to the other monitor
    bind = $mod SHIFT, N, movewindow, mon:+1

    # scratchpad
    bind = $mod, A, togglespecialworkspace, magic
    bind = $mod SHIFT, A, movetoworkspace, special:magic

    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow

    # ---- media / brightness ----
    bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
    bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    bindel = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindel = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    bindel = , XF86MonBrightnessUp, exec, brightnessctl s 5%+
    bindel = , XF86MonBrightnessDown, exec, brightnessctl s 5%-

    bindl = , XF86AudioPlay, exec, playerctl play-pause
    bindl = , XF86AudioNext, exec, playerctl next
    bindl = , XF86AudioPrev, exec, playerctl previous
  '';

  # Seed monitors.conf once. Guarded, so nwg-displays' changes survive
  # every rebuild. Delete the file and rebuild to reset to the host default.
  home.activation.seedMonitors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.config/hypr/monitors.conf" ]; then
      run mkdir -p "$HOME/.config/hypr"
      run cat > "$HOME/.config/hypr/monitors.conf" <<'EOF'
${monitors}
EOF
      run chmod u+w "$HOME/.config/hypr/monitors.conf"
    fi
  '';
}
