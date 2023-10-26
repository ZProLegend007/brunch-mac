# Disable specific chromebooks power settings and apply more generic ones:
# - Enable ambient light sensor support
# - Enable keyboard backlight
# - Enable multiple batteries support
# - Determine the default suspend mode (S0 / S3) according to /sys/power/mem_sleep default value
# - Add "suspend_s0" and "suspend_s3" options to force suspend using S0 or S3 methods
# - Add a more granular backlight management option "advanced_als" (based on pixel slate implementation)

native_chromebook_image=0
for i in $(echo "$1" | sed 's#,# #g')
do
	if [ "$i" == "native_chromebook_image" ]; then native_chromebook_image=1; fi
done

if [ "$native_chromebook_image" -eq 1 ]; then exit 0; fi

if [ -d /roota/usr/share/power_manager/board_specific ]; then rm -r /roota/usr/share/power_manager/board_specific; fi

ret=0

mkdir -p /roota/usr/share/power_manager/board_specific
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 0))); fi

echo 2 > /roota/usr/share/power_manager/board_specific/has_ambient_light_sensor
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 1))); fi

echo 1 > /roota/usr/share/power_manager/board_specific/has_keyboard_backlight
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 2))); fi

echo 1 > /roota/usr/share/power_manager/board_specific/multiple_batteries
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 3))); fi

echo 4 > /roota/usr/share/power_manager/board_specific/low_battery_shutdown_percent
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 4))); fi

if [ $(cat /sys/power/mem_sleep | cut -d' ' -f1) == '[s2idle]' ]; then
	echo 1 > /roota/usr/share/power_manager/board_specific/suspend_to_idle
	if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 5))); fi
fi

for i in $(echo "$1" | sed 's#,# #g')
do
	if [ "$i" == "suspend_s0" ]; then
		echo 1 > /roota/usr/share/power_manager/board_specific/suspend_to_idle
		if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 6))); fi
	fi
	if [ "$i" == "suspend_s3" ]; then
		echo 0 > /roota/usr/share/power_manager/board_specific/suspend_to_idle
		if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 7))); fi
	fi
	if [ "$i" == "advanced_als" ]; then
		cat >/roota/usr/share/power_manager/board_specific/internal_backlight_als_steps <<ALS
10.00 10.00 -1 800
15.00 15.00 800 2000
22.00 22.00 1050 3000
35.00 35.00 2000 5500
50.00 50.00 4000 10000
60.00 60.00 7500 15000
72.00 72.00 12000 35000
85.00 85.00 20000 52500
100.0 100.0 42500 -1
ALS
		if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 8))); fi
	fi
done

exit $ret
