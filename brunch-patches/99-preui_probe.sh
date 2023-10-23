# This patch makes sure iio sensors modules are loaded early, else ChromeOS will consider they do not exist

ret=0
cat >/roota/etc/init/preui-probe.conf <<PREUIPROBE
start on starting boot-services

script
	udevadm trigger --action=add --subsystem-match=pci --subsystem-match=usb --subsystem-match=i2c --subsystem-match=hid --subsystem-match=iio --subsystem-match=uart --subsystem-match=tty --subsystem-match=rfkill
end script
PREUIPROBE
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 0))); fi
exit $ret
