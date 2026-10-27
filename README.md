# android-tv-cleaner

Free up space on any Android TV / Google TV using ADB. No root needed.

## What it does
- Trims app caches
- Stops background apps
- Disables (not uninstalls) apps you list in `debloat.txt`, reversible
- Shows storage before and after

## Setup
1. On the TV: Settings > Device Preferences > About > tap **Build** 7 times.
2. Settings > Device Preferences > Developer options > enable **USB debugging** (and **Network debugging** for Wi-Fi).
3. Install [Android platform-tools](https://developer.android.com/tools/releases/platform-tools) on your computer.

## Run
```bash
chmod +x clean-tv.sh
./clean-tv.sh -i 192.168.1.50     # Wi-Fi (use your TV's IP)
./clean-tv.sh                     # USB
./clean-tv.sh -r                  # re-enable apps from debloat.txt
```
Approve the "Allow debugging" prompt on the TV the first time. Each step asks for confirmation.

## Notes
- Use at your own risk. Never disable system/launcher/Play Services packages.
- Caches are rebuilt by apps as needed.

## License
MIT
