#!/bin/sh
# sta interface daemon for qcawifi. zhangzf 2017
#

DISABLED=0
TIMER=$((2*60))

[ -f "/lib/wifi/qcawifi.sh" ] || exit 0
ps | grep -q [q]cawifi-sta-daemon && exit 0

. /lib/functions.sh
. /lib/functions/network.sh

load_wireless() {
	local cfg=$1
	local mode

	config_get mode "$cfg" mode
	[ "$mode" = "sta" ] && {
		uci set wireless.${cfg}.disabled=$DISABLED
		uci commit wireless
		wifi reload
	}
}

disable_qcawifi() {
	local sta_num

	[ "$DISABLED" -eq 1 ] && {
		network_get_physdev dev wan

		sta_num=$(wlanconfig ${dev:0:4} list | grep -v ADDR | wc -l)
		[ "$sta_num" -gt 0 ] && return 0
	}

	DISABLED=$((DISABLED^1))

	config_load wireless
	config_foreach load_wireless wifi-iface
}

while : ; do
	sleep $TIMER

	STA_MODE=$(uci -q get network.wan.apclient)

	[ "${STA_MODE:-0}" -eq 0 ] && break

	network_is_up && continue

	disable_qcawifi
done

exit 0