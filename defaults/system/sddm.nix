{ config, lib, pkgs, ... }:
let
  t = import ../theme.nix;

  # SDDM runs as its own user before login, so it cannot read anything
  # under /home. The wallpaper has to come from the nix store.
  wallpaper = ../../assets/wallpapers/default.jpg;

  mainQml = pkgs.writeText "Main.qml" ''
    import QtQuick 2.15
    import QtQuick.Controls 2.15

    Rectangle {
        id: root
        width: 1920
        height: 1080
        color: "#${t.bg}"

        property color accent:  "#${t.accent}"
        property color fg:      "#${t.fg}"
        property color fgDim:   "#${t.fgDim}"
        property color surface: "#${t.surface}"
        property color urgent:  "#${t.urgent}"

        // Wallpaper. No blur effect: Qt5Compat.GraphicalEffects is not
        // reliably present in the sddm greeter's QML import path, and a
        // failed import takes the whole greeter down. A dark overlay
        // gives a similar result with no extra dependency.
        // Mutable path outside the nix store so sddm-wallpaper-set can
        // replace it without a rebuild. Seeded by systemd.tmpfiles below.
        Image {
            anchors.fill: parent
            source: "file:///var/lib/sddm-wallpaper/wallpaper.jpg"
            fillMode: Image.PreserveAspectCrop
            asynchronous: false
            cache: false
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.62
        }

        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -170
            color: root.fg
            font.pointSize: 68
            font.bold: true
            text: Qt.formatDateTime(new Date(), "HH:mm")

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: clock.bottom
            anchors.topMargin: 2
            color: root.fgDim
            font.pointSize: 13
            text: Qt.formatDateTime(new Date(), "dddd, dd MMMM")
        }

        Text {
            id: userLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: pwField.top
            anchors.bottomMargin: 20
            color: root.fg
            font.pointSize: 14
            text: typeof userModel !== "undefined" && userModel.lastUser
                  ? userModel.lastUser : "user"
        }

        Rectangle {
            id: pwField
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 40
            width: 320
            height: 52
            radius: 26
            color: Qt.rgba(root.surface.r, root.surface.g, root.surface.b, 0.22)
            border.width: 2
            border.color: pwInput.activeFocus
                          ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.8)
                          : Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.35)

            TextInput {
                id: pwInput
                anchors.fill: parent
                anchors.leftMargin: 22
                anchors.rightMargin: 22
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                color: root.fg
                font.pointSize: 13
                echoMode: TextInput.Password
                focus: true
                clip: true

                onAccepted: sddm.login(userLabel.text, pwInput.text, 0)

                Text {
                    anchors.centerIn: parent
                    visible: pwInput.text.length === 0
                    color: root.fgDim
                    font.pointSize: 12
                    font.italic: true
                    text: "password"
                }
            }
        }

        Text {
            id: errorLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: pwField.bottom
            anchors.topMargin: 14
            color: root.urgent
            font.pointSize: 11
            visible: false
            text: "incorrect password"
        }

        Connections {
            target: sddm
            function onLoginFailed() {
                errorLabel.visible = true
                pwInput.text = ""
                pwInput.forceActiveFocus()
            }
        }

        Component.onCompleted: pwInput.forceActiveFocus()
    }
  '';

  metadata = pkgs.writeText "metadata.desktop" ''
    [SddmGreeterTheme]
    Name=rog
    Description=Matches hyprlock
    Author=local
    License=MIT
    Type=sddm-theme
    Version=1.0
    MainScript=Main.qml
    QtVersion=6
  '';

  # Root-only helper. Validates that the argument is a real image before
  # copying, so the sudo rule cannot be used to write arbitrary files.
  setSddmWallpaper = pkgs.writeShellScriptBin "sddm-wallpaper-set" ''
    set -eu
    src="''${1:-}"
    [ -n "$src" ] || { echo "usage: sddm-wallpaper-set <image>" >&2; exit 1; }
    [ -f "$src" ] || { echo "not a file: $src" >&2; exit 1; }
    case "$(${pkgs.file}/bin/file -b --mime-type "$src")" in
      image/*) ;;
      *) echo "not an image: $src" >&2; exit 1 ;;
    esac
    ${pkgs.coreutils}/bin/install -D -m 0644 -o root -g root \
      "$src" /var/lib/sddm-wallpaper/wallpaper.jpg
  '';

  sddmTheme = pkgs.runCommand "sddm-theme-rog" { } ''
    d=$out/share/sddm/themes/rog
    mkdir -p $d
    cp ${mainQml}  $d/Main.qml
    cp ${metadata} $d/metadata.desktop
    cp ${wallpaper} $d/wallpaper.jpg
  '';
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;

    # KEEP COMMENTED until the greeter is confirmed working. A QML error
    # in a custom theme drops you to a TTY with no desktop. Uncomment,
    # rebuild, then `systemctl restart display-manager` from a TTY so a
    # failure is one command to undo rather than a reboot.
    theme = "rog";

    extraPackages = with pkgs.kdePackages; [
      qtsvg
      qtdeclarative
      qt5compat
    ];
  };

  environment.systemPackages = [ sddmTheme setSddmWallpaper ];

  # Seed the greeter wallpaper once. "C" copies only if the target does
  # not already exist, so a wallpaper chosen at runtime survives rebuilds.
  systemd.tmpfiles.rules = [
    "d /var/lib/sddm-wallpaper 0755 root root -"
    "C /var/lib/sddm-wallpaper/wallpaper.jpg 0644 root root - ${wallpaper}"
  ];

  # sddm-wallpaper-picker (in defaults/home/wallpaper.nix) calls this via
  # sudo. The rule must name the path the CALLER actually invokes: sudo
  # matches on the command as typed, and PATH resolves this to
  # /run/current-system/sw/bin/... — pointing the rule at the raw store
  # path never matches, and every call falls through to a password
  # prompt.
  #
  # The path is stable but its target changes with each rebuild, so this
  # does not pin one exact binary. What actually constrains the rule is
  # the mime-type check inside the script above.
  security.sudo.extraRules = [{
    groups = [ "wheel" ];
    commands = [{
      command = "/run/current-system/sw/bin/sddm-wallpaper-set";
      options = [ "NOPASSWD" ];
    }];
  }];
}
