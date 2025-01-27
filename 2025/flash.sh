#!/bin/bash

OUTPUT_DEVICE=/dev/mmcblk0
OUTPUT_MNT=/media/emmc
SOURCE_IMG=/media/exfat/Armbian-unofficial_25.02.0-trunk_Rock-5c_jammy_vendor_6.1.84.img
USB_STICK=/media/exfat
USB_STICK_DEVICE=/dev/sda1

mkdir -p $USB_STICK
mount -t exfat $USB_STICK_DEVICE $USB_STICK

dd if=$SOURCE_IMG of=$OUTPUT_DEVICE bs=4M status=progress

mkdir -p $OUTPUT_MNT
mount ${OUTPUT_DEVICE}p1 $OUTPUT_MNT

#cp $USB_STICK/.not_logged_in_yet $OUTPUT_MNT/root/

# Run on Pi
#
# Note: You may still need to log in as root / 1234 on first log in
#       See extensions/preset-firstrun.sh for the default boot values
#
# `nmcli device wifi connect d-Guest password mercury+balmy`
#
# This is needed in order to route internet over the wifi by default
# `nmcli connection modify "netplan-eth0" ipv4.gateway 10.59.0.1 ipv4.route-metric 1000`
# `nmcli connection down "netplan-eth0" && nmcli connection up "netplan-eth0"`
#
# Modify the IP here for whatever is needed on this pi
# `nmcli connection modify "netplan-eth0" ipv4.addr 10.59.40.12`
#
# On this run, you will now lose connection to the pi. Power off, pop off the eMMC module
# `nmcli connection down "netplan-eth0" && nmcli connection up "netplan-eth0"`
#
