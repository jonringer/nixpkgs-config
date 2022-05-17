{ lib, coreutils, gnused, pulseaudio, pamixer, pipewire, writeShellScript }:

# Largely influenced from https://github.com/victortrac/polybar-scripts/blob/master/polybar-scripts/pipewire/pipewire.sh

writeShellScript "pipewire.sh" ''

PATH=${lib.makeBinPath [ coreutils gnused pamixer pulseaudio pipewire ]}

function main() {
    VOLUME=$(pamixer --get-volume-human)

    case $1 in
        "up")
            pamixer --increase 10
            ;;
        "down")
            pamixer --decrease 10
            ;;
        "mute")
            pamixer --toggle-mute
            ;;
        *)

        echo "''${VOLUME}"
    esac

}

main "$@"
''
