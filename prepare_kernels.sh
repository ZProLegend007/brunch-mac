#!/bin/bash

apply_patches()
{
for patch_type in "base" "others" "chromeos" "all_devices" "macbook"; do
	if [ -d "./kernel-patches/$1/$patch_type" ]; then
		for patch in ./kernel-patches/"$1/$patch_type"/*.patch; do
			echo "Applying patch: $patch"
			patch -d"./kernels/$1" -p1 --no-backup-if-mismatch -N < "$patch" || { echo "Kernel $1 patch failed"; exit 1; }
		done
	fi
done
}

make_config()
{
sed -i -z 's@# Detect buggy gcc and clang, fixed in gcc-11 clang-14.\n\tdef_bool@# Detect buggy gcc and clang, fixed in gcc-11 clang-14.\n\tdef_bool $(success,echo 0)\n\t#def_bool@g' ./kernels/$1/init/Kconfig
if [ "x$1" == "xchromebook-4.14" ] || [ "x$1" == "xchromebook-4.19" ]; then config_subfolder=""; else config_subfolder="/chromeos"; fi
case "$1" in
	*)
		echo 'CONFIG_LOCALVERSION="-brunch-mac"' > "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel $1 configuration failed"; exit 1; }
#		sed '/CONFIG_DEBUG_INFO\|CONFIG_MODULE_COMPRESS/d' "./kernels/$1/chromeos/config$config_subfolder/base.config" >> "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel $1 configuration failed"; exit 1; }
#		sed '/CONFIG_DEBUG_INFO\|CONFIG_MODULE_COMPRESS/d' "./kernels/$1/chromeos/config$config_subfolder/x86_64/common.config" >> "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel $1 configuration failed"; exit 1; }
#		sed '/CONFIG_DEBUG_INFO\|CONFIG_MODULE_COMPRESS/d' "./kernels/$1/chromeos/config$config_subfolder/x86_64/chromeos-intel-pineview.flavour.config" >> "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel $1 configuration failed"; exit 1; }
		cat "./kernel-patches/brunch_configs"  >> "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel $1 configuration failed"; exit 1; }
		make -C "./kernels/$1" O=out chromeos_defconfig || { echo "Kernel $1 configuration failed"; exit 1; }
		cp "./kernels/$1/out/.config" "./kernels/$1/arch/x86/configs/chromeos_defconfig" || { echo "Kernel $1 configuration failed"; exit 1; }
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
kernels="6.1"
for kernel in $kernels; do
	kernel_version=$(curl -Ls "https://chromium.googlesource.com/chromiumos/third_party/kernel/+/$kernel_remote_path$kernel/Makefile?format=TEXT" | base64 --decode | sed -n -e 1,4p | sed -e '/^#/d' | cut -d'=' -f 2 | sed -z 's#\n##g' | sed 's#^ *##g' | sed 's# #.#g')
	echo "kernel_version=$kernel_version"
	[ ! "x$kernel_version" == "x" ] || { echo "Kernel version not found"; exit 1; }
	case "$kernel" in
		6.1)
			echo "Downloading ChromiumOS kernel source for kernel $kernel version $kernel_version"
			echo "Manually downloading kernel 6.1.30..."
			curl -L "https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/a343b0dd87b42ba9d508fbf7d0c06f744c2e0954.tar.gz" -o "./kernels/chromiumos-$kernel.tar.gz" || { echo "Kernel source download failed"; exit 1; }
			mkdir "./kernels/chromebook-6.1" #"./kernels/6.1"
			tar -C "./kernels/chromebook-6.1" -zxf "./kernels/chromiumos-$kernel.tar.gz" || { echo "Kernel $kernel source extraction failed"; exit 1; }
			rm -f "./kernels/chromiumos-$kernel.tar.gz"
			apply_patches "chromebook-6.1"
			make_config "chromebook-6.1"
		;;
	esac
done
}

rm -rf ./kernels
mkdir ./kernels

chromeos_version="R121"
download_and_patch_kernels

