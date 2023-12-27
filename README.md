[license-url]: ./LICENSE
[license-shield]: https://img.shields.io/github/license/sebanc/brunch?label=License&logo=Github&style=flat-square

<h1 align="center">Brunch-mac Framework</h1>
<h4 align="center">The Brunch Framework modified for compatibility and optimization for T2 Macs</h4>

[![License][license-shield]][license-url]

### Brunch-mac is currently in the testing phase.

I am currently testing Brunch-mac with multiple kernels to find the most stable and useable kernel.

**Kernel 5.10** - Touchbar doesn't change modes, No audio, No suspend.

**Kernel 6.1** - No Bluetooth, No audio, No suspend, Possible touchpad issues with MacBook Pro 2020.

~~**Kernel 6.6** - No Bluetooth, No audio, Touchbar issues with new driver, Wi-Fi DHCP lookup error, No suspend, Shutdown issues.~~

**T2 Kernel???**

## Install Instructions

This install guide assumes you already have Windows Bootcamp or linux installed on your device.

To install please download the latest release and place it in a folder on your chosen OS (other than MacOS). Then head to [this website](https://cros.tech/device/shyvana/) and download the latest chromeOS image, then also place that file in your folder. 

Then with either WSL or a linux terminal `cd` into your folder and run the command `tar -zxvf *brunchmacfile.tar.gz*`. Make sure to replace the *brunchmacfile* with the actual name of the brunch-mac file that you downloaded. **TIP: Use tab to autofill the file name.**

Once that has finished run the command `sudo bash chromeos-install.sh -src *downloadedchromeosimgfile.bin* -dst /choose/a/path/chromeos.img -s *yourchosendisksize*`. Make sure to replace *downloadedchromeosimgfile.bin* with the name of the downloaded chromeOS image file, and to replace the */choose/a/path/* with your own chosen path for brunch-mac. **Make sure if you are using WSL that the chosen path starts with `/mnt/c/` so that you are targeting your C: drive.** Also replace *yourchosendisksize* with the disk size that you want for chromeOS. Make sure you have enough storage for your chosen size. That process should take some time.

Once the install is completed, if this is your first time installing, make sure to type in 'mboot' when requested so that you get a Grub menuentry file.

After that is completed, depending on your setup you will need to install Grub on your Mac. The easiest way to do this is from a linux OS that is already installed. If you don't have this you may need to find another way to install Grub. **Note: You can't install Grub2Win on a MacBook as Windows has no access to the EFI partition.**

Once you have grub installed you will need to add the previously made Grub menuentry file to Grub. If you are using linux I recommend installing grub-configurator to simplify this and customize Grub. After that you should have brunch-mac/chromeOS installed! 

## Updating and Settings

### Make sure you add [this PWA](https://zprolegend007.github.io/brunch-mac-pwa/) so you can update brunch-mac.

Most people will not need to use brunch-mac settings as most configs for Macs are enabled by default. But if you are having any issues or want to change some extra setttings you should check it out. 

## Help and Issues

If you run into any problems, issues or need any help feel free to make an issue and I'll make sure to help out as soon as I can!

## Check out the original [Brunch Framework](https://github.com/sebanc/brunch)

This repo was a fork of the [brunch-unstable](https://github.com/sebanc/brunch-unstable) building repo, credit to sebanc for the original Brunch Framework and all the effort that he has put in to get it to where it is today. For more information on this project, check out his repo.
