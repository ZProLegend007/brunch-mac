[license-url]: ./LICENSE
[license-shield]: https://img.shields.io/github/license/sebanc/brunch?label=License&logo=Github&style=flat-square

<h1 align="center">Brunch-mac Framework</h1>
<h3 align="center">A fork of the Brunch Framework focused on optimization for T2 MacBooks</h3>

[![License][license-shield]][license-url]

## Install instructions

To install this fork please download the latest release and place it in a folder. Then head to [this website](https://cros.tech/device/shyvana/) and download the latest chromeOS image, then also place that file in your folder. 

Then with either WSL or a linux terminal `cd` into your folder and run the command `tar -zxvf *brunchmacfile.tar.gz*`. Make sure to replace the *brunchmacfile* with the actual name of the brunch-mac file that you downloaded. **TIP: Use tab to autofill the file name.**

Once that has finished run the command `sudo bash chromeos-install.sh -src *downloadedchromeosimgfile.bin* -dst /choose/a/path/chromeos.img -s *yourchosendisksize*`. Make sure to replace *downloadedchromeosimgfile.bin* with the name of the downloaded chromeOS image file, and to replace the */choose/a/path/* with your own chosen path for brunch-mac. **Make sure if you are using WSL that the chosen path starts with `/mnt/c/` so that you are targeting your C: drive.** Also replace *yourchosendisksize* with the disk size that you want for chromeOS. Make sure you have enough storage for your chosen size. That process should take some time.

Once the install is completed, if this is your first time installing, make sure to type in 'multiboot' when requested so that you get a Grub menuentry file.

After that is completed, depending on your setup you will need to install Grub on your Mac. The easiest way to do this is from a linux OS that is already installed. If you don't have this you may need to find another way to install Grub. **Note: You can't install Grub2Win on a MacBook as Windows has no access to the EFI partition.**

Once you have grub installed you will need to add the previously made Grub menuentry file to Grub. If you are using linux I recommend installing grub-configurator to simplify this and customize Grub.

After that you should have brunch-mac/chromeOS installed! Most people will not need to use brunch-mac settings as most configs for Macs are enabled by default. If you run into any issues or need any help feel free to make an issue!

## Check out the original [Brunch Framework](https://github.com/sebanc/brunch)

This repo is a fork of the Brunch-unstable building repo, credit to sebanc for the original Brunch Framework and all the effort that he has put in to get it to where it is today. For more information on this project, check out his repo.
