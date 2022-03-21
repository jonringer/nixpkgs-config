{ lib, coreutils, gnused, pulseaudio, pamixer, pipewire, writeShellScript }:

# Largely influenced from https://github.com/victortrac/polybar-scripts/blob/master/polybar-scripts/pipewire/pipewire.sh

writeShellScript "pipewire.sh" ''

PATH=${lib.makeBinPath [ coreutils gnused pamixer pulseaudio pipewire ]}

function main() {
    DEFAULT_SOURCE=$(pw-record --list-targets | sed -n 's/^*[[:space:]]*[[:digit:]]\+: source description="\(.*\)" prio=[[:digit:]]\+$/\1/p')
    DEFAULT_SINK=$(pw-play --list-targets | sed -n 's/^*[[:space:]]*[[:digit:]]\+: sink description="\(.*\)" prio=[[:digit:]]\+$/\1/p')
    VOLUME=$(pamixer --get-volume-human)

    if [ "''${action}" == "up" ]; then
        pamixer --increase 10
    elif [ "''${action}" == "down" ]; then
        pamixer --decrease 10
    elif [ "''${action}" == "mute" ]; then
        pamixer --toggle-mute
    fi

    echo " ''${DEFAULT_SOURCE} |   ''${VOLUME}"
}

main "$@"
''
