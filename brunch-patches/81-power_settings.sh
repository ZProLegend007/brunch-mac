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
12.00 12.00 -1 600
20.00 20.00 600 3000
25.00 25.00 2050 6000
38.00 38.00 5000 10500
52.00 52.00 8000 16000
62.00 62.00 14500 28000
72.00 72.00 20000 38000
85.00 85.00 30000 58000
100.0 100.0 52500 -1
ALS
		if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 8))); fi
	fi
done

exit $ret
