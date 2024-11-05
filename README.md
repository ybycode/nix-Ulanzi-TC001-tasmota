This provides a set of bash scripts defined in a nix-shell script, that allow
to quickly flash and configure Tasmotaon the Ulanzi TC001 LED matrix (ESP32
under the hood).

# Firmware download

The factory firmware can be downloaded from: https://ota.tasmota.com/tasmota32/release/tasmota32.factory.bin.

# Flashing & wifi configuration

```bash
$ nix-shell
[nix-shell] $ tc001-serial-erase-flash
[nix-shell] $ tc001-serial-flash-firmware ./tasmota32.factory.bin && tc001-serial-setup
[nix-shell] $ tc001-serial-setup-wifi
```

# Links

- https://templates.blakadder.com/ulanzi_TC001.html
- Tasmota Web Installer: https://tasmota.github.io/install/
- https://github.com/Hypfer/ulanzi-tc001-tasmota
- https://github.com/iliaan/ulanzi-lab
- https://berry-lang.github.io/
- Esptool: https://github.com/espressif/esptool/
