#!/usr/bin/env bash
# android-tv-cleaner: free up space on Android TV / Google TV over ADB.
# Usage: ./clean-tv.sh [-i TV_IP] [-r]
#   -i  TV IP address (connects over Wi-Fi, port 5555)
#   -r  restore apps listed in debloat.txt (re-enable)
set -u

IP=""
RESTORE=0
while getopts "i:r" opt; do
  case "$opt" in
    i) IP="$OPTARG" ;;
    r) RESTORE=1 ;;
    *) echo "Usage: $0 [-i TV_IP] [-r]"; exit 1 ;;
  esac
done

ask() { read -r -p "$1 [y/N] " a; [[ "$a" =~ ^[Yy]$ ]]; }

command -v adb >/dev/null || { echo "adb not found. Install Android platform-tools first."; exit 1; }

if [[ -n "$IP" ]]; then
  adb connect "$IP:5555" || exit 1
fi

count=$(adb devices | awk 'NR>1 && $2=="device"' | wc -l)
if [[ "$count" -ne 1 ]]; then
  echo "Need exactly one authorized device, found $count. Check USB debugging and approve the prompt on the TV."
  exit 1
fi

DEBLOAT_FILE="$(dirname "$0")/debloat.txt"

if [[ "$RESTORE" -eq 1 ]]; then
  [[ -f "$DEBLOAT_FILE" ]] || { echo "debloat.txt not found."; exit 1; }
  grep -vE '^\s*(#|$)' "$DEBLOAT_FILE" | while read -r pkg; do
    echo "Re-enabling $pkg"
    adb shell pm enable "$pkg"
  done
  echo "Done."
  exit 0
fi

echo "== Storage before =="
adb shell df /data

if ask "Step 1: Trim app caches on all apps?"; then
  adb shell pm trim-caches 999999999999 || echo "Trim failed (not supported on this device)."
fi

if ask "Step 2: Stop all background apps?"; then
  adb shell am kill-all
fi

if [[ -f "$DEBLOAT_FILE" ]]; then
  pkgs=$(grep -vE '^\s*(#|$)' "$DEBLOAT_FILE")
  if [[ -n "$pkgs" ]]; then
    echo "Step 3: Packages in debloat.txt that will be DISABLED (reversible with -r):"
    echo "$pkgs"
    if ask "Disable these packages?"; then
      echo "$pkgs" | while read -r pkg; do
        echo "Disabling $pkg"
        adb shell pm disable-user --user 0 "$pkg"
      done
    fi
  else
    echo "Step 3: skipped (debloat.txt has no active entries)."
  fi
fi

echo "== Storage after =="
adb shell df /data

if ask "Reboot the TV now?"; then
  adb reboot
fi
