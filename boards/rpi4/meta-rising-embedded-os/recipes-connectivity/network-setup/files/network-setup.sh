#!/bin/sh
# network-setup.sh
# Minimal Wi-Fi setup: associates with AP using wpa_supplicant and gets
# DHCPv4 via udhcpc. SSID and password are read from WPA_CONF locally.

IFACE="wlan0"
WPA_CONF="/etc/wpa_supplicant.conf"
WPA_PID="/var/run/wpa_supplicant.pid"

# Unblock Wi-Fi adapter (rfkill)
rfkill unblock wifi

# Bring interface up
ip link set "$IFACE" up

# Kill any stale wpa_supplicant instance
if [ -f "$WPA_PID" ]; then
    kill "$(cat "$WPA_PID")" 2>/dev/null
    rm -f "$WPA_PID"
fi

# Start wpa_supplicant in background
wpa_supplicant -B -i "$IFACE" -c "$WPA_CONF" -P "$WPA_PID"

# Wait for association (up to 20 seconds)
TIMEOUT=20
ELAPSED=0
while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
    STATE=$(wpa_cli -i "$IFACE" status 2>/dev/null | grep "^wpa_state" | cut -d= -f2)
    if [ "$STATE" = "COMPLETED" ]; then
        break
    fi
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done

if [ "$STATE" != "COMPLETED" ]; then
    echo "network-setup: Wi-Fi association failed after ${TIMEOUT}s" >&2
    exit 1
fi

# Request DHCPv4
udhcpc -i "$IFACE" -q -n

echo "network-setup: Wi-Fi up on $IFACE"
