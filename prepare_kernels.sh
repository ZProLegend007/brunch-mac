#!/bin/bash

apply_patches()
{
for patch_type in "base" "others" "chromeos" "all_devices" "surface_devices" "surface_go_devices" "surface_mwifiex_pcie_devices" "surface_np3_devices"; do
	if [ -d "./kernel-patches/$1/$patch_type" ]; then
		for patch in ./kernel-patches/"$1/$patch_type"/*.patch; do
			echo "Applying patch: $patch"
			patch -d"./kernels/$1" -p1 --no-backup-if-mismatch -N < "$patch" || { echo "Kernel patch failed"; }
			cat ./kernels/*/drivers/gpu/drm/i915/display/intel_fb.c.rej
		done
	fi
done
}

make_config()
{
sed -i -z 's@# Detect buggy gcc and clang, fixed in gcc-11 clang-14.\n\tdef_bool@# Detect buggy gcc and clang, fixed in gcc-11 clang-14.\n\tdef_bool $(success,echo 0)\n\t#def_bool@g' ./kernels/$1/init/Kconfig
if [ "x$1" == "x5.15" ] || [ "x$1" == "x5.10" ] || [ "x$1" == "x5.4" ] || [ "x$1" == "xmacbook" ] || [ "x$1" == "xchromebook-5.4" ]; then config_subfolder="/chromeos"; fi 
case "$1" in
	5.15|5.10|5.4|4.19|macbook)
		make -C "./kernels/$1" O=out allmodconfig || { echo "Kernel configuration failed"; exit 1; }
		sed '/CONFIG_AMD\|CONFIG_ATH\|CONFIG_AXP\|CONFIG_B4\|CONFIG_BACKLIGHT\|CONFIG_BATTERY\|CONFIG_BCM\|CONFIG_BN\|CONFIG_BRCM\|CONFIG_BRIDGE\|CONFIG_BT\|CONFIG_CEC\|CONFIG_CFG\|CONFIG_CHARGER\|CONFIG_CRYPTO\|CONFIG_DRM_AMD\|CONFIG_DRM_GMA\|CONFIG_DRM_NOUVEAU\|CONFIG_DRM_RADEON\|CONFIG_DW_DMAC\|CONFIG_EXTCON\|CONFIG_FIREWIRE\|CONFIG_FRAMEBUFFER_CONSOLE\|CONFIG_GENERIC\|CONFIG_GPIO\|CONFIG_HID\|CONFIG_I2C\|CONFIG_INET\|CONFIG_INPUT\|CONFIG_INTEL\|CONFIG_IP\|CONFIG_IWL\|CONFIG_JOYSTICK\|CONFIG_KEYBOARD\|CONFIG_LEDS\|CONFIG_LIB\|CONFIG_MAC\|CONFIG_MANAGER\|CONFIG_MEDIA_CONTROLLER\|CONFIG_MFD\|CONFIG_ML\|CONFIG_MMC\|CONFIG_MOUSE\|CONFIG_MT7\|CONFIG_MW\|CONFIG_NET\|CONFIG_NFC\|CONFIG_NL\|CONFIG_PATA\|CONFIG_POWER\|CONFIG_PWM\|CONFIG_REGULATOR\|CONFIG_RMI\|CONFIG_RT\|CONFIG_SATA\|CONFIG_SCSI\|CONFIG_SENSORS\|CONFIG_SND\|CONFIG_SPI\|CONFIG_SQUASHFS\|CONFIG_SSB\|CONFIG_TABLET\|CONFIG_TCP\|CONFIG_THUNDERBOLT\|CONFIG_TOUCHSCREEN\|CONFIG_TPS68470\|CONFIG_TYPEC\|CONFIG_USB\|CONFIG_VHOST\|CONFIG_VIDEO\|CONFIG_W1\|CONFIG_WL\|CONFIG_XDP\|CONFIG_XFRM/!d' "./kernels/$1/out/.config" > "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel configuration failed"; exit 1; }
		make -C "./kernels/$1" O=out allyesconfig || { echo "Kernel configuration failed"; exit 1; }
		sed '/CONFIG_ATA\|CONFIG_CROS\|CONFIG_HOTPLUG\|CONFIG_MDIO\|CONFIG_PCI\|CONFIG_SATA\|CONFIG_SERI\|CONFIG_USB_STORAGE\|CONFIG_USB_XHCI\|CONFIG_USB_OHCI\|CONFIG_USB_EHCI\|CONFIG_VIRTIO/!d' "./kernels/$1/out/.config" >> "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel configuration failed"; exit 1; }
		sed -i '/_DBG\|_DEBUG\|_MOCKUP\|_NOCODEC\|_WARNINGS\|TEST\|USB_OTG\|_PLTFM\|_PLATFORM/d' "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel configuration failed"; exit 1; }
		sed '/CONFIG_ATH\|CONFIG_IWL\|CONFIG_MODULE_COMPRESS\|CONFIG_MOUSE/d' "./kernels/$1/chromeos/config$config_subfolder/base.config" >> "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel configuration failed"; exit 1; }
		sed '/CONFIG_ATH\|CONFIG_IWL\|CONFIG_MODULE_COMPRESS\|CONFIG_MOUSE/d' "./kernels/$1/chromeos/config$config_subfolder/x86_64/common.config" >> "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel configuration failed"; exit 1; }
		cat "./kernel-patches/$1/brunch_configs"  >> "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel configuration failed"; exit 1; }
		make -C "./kernels/$1" O=out chromeos_defconfig || { echo "Kernel configuration failed"; exit 1; }
		cp "./kernels/$1/out/.config" "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel configuration failed"; exit 1; }
	;;
	*)
		sed '/CONFIG_MODULE_COMPRESS/d' "./kernels/$1/chromeos/config$config_subfolder/base.config" > "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel configuration failed"; exit 1; }
		sed '/CONFIG_MODULE_COMPRESS/d' "./kernels/$1/chromeos/config$config_subfolder/x86_64/common.config" >> "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel configuration failed"; exit 1; }
		sed '/CONFIG_MODULE_COMPRESS/d' "./kernels/$1/chromeos/config$config_subfolder/x86_64/chromeos-intel-pineview.flavour.config" >> "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel configuration failed"; exit 1; }
		cat "./kernel-patches/$1/brunch_configs"  >> "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel configuration failed"; exit 1; }
		make -C "./kernels/$1" O=out chromeos_defconfig || { echo "Kernel configuration failed"; exit 1; }
		cp "./kernels/$1/out/.config" "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel configuration failed"; exit 1; }
	;;
esac
}

download_and_patch_kernels()
{
# Find the ChromiumOS kernel remote path corresponding to the release
kernel_remote_path="$(git ls-remote https://chromium.googlesource.com/chromiumos/third_party/kernel/ | grep "refs/heads/release-$chromeos_version" | head -1 | sed -e 's#.*\t##' -e 's#chromeos-.*##' | sort -u)chromeos-"
[ ! "x$kernel_remote_path" == "x" ] || { echo "Remote path not found"; exit 1; }
echo "kernel_remote_path=$kernel_remote_path"

# Download kernels source
kernels="5.15"
for kernel in $kernels; do
	kernel_version=$(curl -Ls "https://chromium.googlesource.com/chromiumos/third_party/kernel/+/$kernel_remote_path$kernel/Makefile?format=TEXT" | base64 --decode | sed -n -e 1,4p | sed -e '/^#/d' | cut -d'=' -f 2 | sed -z 's#\n##g' | sed 's#^ *##g' | sed 's# #.#g')
#	echo "kernel_version=$kernel_version"
	[ ! "x$kernel_version" == "x" ] || { echo "Kernel version not found"; exit 1; }
	case "$kernel" in
		5.15)
			echo "Manually downloading kernel 5.15.146..."
			curl -L "https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/26c690eff0a56293e0b6911a38e406c211b35547.tar.gz" -o "./kernels/chromiumos-$kernel.tar.gz" || { echo "Kernel source download failed"; exit 1; }
			mkdir "./kernels/macbook"
			tar -C "./kernels/macbook" -zxf "./kernels/chromiumos-$kernel.tar.gz" || { echo "Kernel source extraction failed"; exit 1; }
			rm -f "./kernels/chromiumos-$kernel.tar.gz"
			echo "Replacing loop.c with file from kernel 5.10..."
			mv ./kernel-patches/loop.c ./kernels/macbook/drivers/block/loop.c || { echo "Failed loop.c replacement."; exit 1; }
			apply_patches "macbook"
			make_config "macbook"
		;;
	esac
done
}

rm -rf ./kernels
mkdir ./kernels

chromeos_version="R121"
download_and_patch_kernels