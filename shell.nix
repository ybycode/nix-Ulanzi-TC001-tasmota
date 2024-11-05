{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/836658e7210e6277b8091e86ca65c6a756e6881e.tar.gz") {}
}:

with pkgs;
let
  serial_port = "/dev/ttyUSB0";

  baud_rate = "115200";

  tasmota_template = ''{"NAME":"Ulanzi TC001","GPIO":[0,0,0,0,0,0,0,0,0,0,34,480,0,0,0,0,0,640,608,0,0,0,32,33,0,0,0,0,1376,0,4705,4768,0,0,0,0],"FLAG":0,"BASE":1}'';

  cmdPrefix = "tc001-serial-";
  prefixedCmd = name: "${cmdPrefix}${name}";

  esptool_base_cmd = ''
    ${pkgs.esptool}/bin/esptool.py \
      --chip esp32 \
      --baud ${baud_rate} \
      --port ${serial_port}'';

in mkShell {
  name = "nervesShell";

  buildInputs = [
    esptool # for everything related to flashing the esp32 chip
    picocom # terminal emulation program, over serial port

    (writeShellApplication {
      name = prefixedCmd "erase-flash";
      runtimeInputs = [ esptool ];
      text = "${esptool_base_cmd} erase_flash";
    })
    (writeShellApplication {
      name = prefixedCmd "flash-firmware";
      runtimeInputs = [ esptool ];

      text = ''
      if [[ $# != 1 ]]; then
        echo >&2 "ERROR: expecting 1 argument:"
        echo >&2 "USAGE: $(basename "$0") FIRMWARE_FILE"
        echo >&2 "exiting."
        exit 1
      fi

      firmware_bin_file="$1"
      ${esptool_base_cmd} write_flash 0x0 "$firmware_bin_file"
      '';
    })
    (writeShellApplication {
      name = prefixedCmd "setup";
      runtimeInputs = [ ];

      text = ''
        stty -F ${serial_port} ${baud_rate} cs8 -cstopb -parenb

        template='${tasmota_template}'

        echo "Backlog Template $template; Pixels 256; Module 0" > ${serial_port}
      '';
    })
    (writeShellApplication {
      name = prefixedCmd "setup-wifi";
      runtimeInputs = [ ];

      text = ''
        if [[ -z "''\${WIFI_SSID:-}" ]] || [[ -z "''\${WIFI_PASSWORD:-}" ]]; then
          echo >&2 "ERROR: env var WIFI_SSID or WIFI_PASSWORD not defined."
          echo >&2 "USAGE: WIFI_SSID=\"mywify\" WIFI_PASSWORD=123 $(basename "$0")"
          echo >&2 "exiting."
          exit 1
        fi

        stty -F ${serial_port} ${baud_rate} cs8 -cstopb -parenb
        sleep 0.1
        echo "Backlog SSID1 $WIFI_SSID; PASSWORD1 $WIFI_PASSWORD" > ${serial_port}
      '';
    })
  ];

  shellHook = ''
    alias vim=nvim
    alias pc="picocom -b ${baud_rate} ${serial_port} --echo --omap crcrlf"
    echo
    echo "Commands brought by the shell:"
    echo
    compgen -c "${cmdPrefix}"
  '';
}
