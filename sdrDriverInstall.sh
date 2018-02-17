#!/bin/bash
# Created by Matthew Miller
# 12AUG2015
# Downloads, builds, and installs driver for using a RTL-SDR USB SDR

RTL_BUILD_DIR=~/rtl_build

set -e

if [ "$(whoami)" != "root" ]; then
	echo "ERROR: This script be run as root!"
	exit 1
fi

# Based off of the following guide
#http://www.algissalys.com/index.php/amateur-radio/88-raspberry-pi-sdr-dongle-aprs-igate



#Install dependencies
echo '**** Installing dependencies ****'
apt-get -y install git build-essential cmake libusb-1.0-0-dev sox libtool autoconf automake libfftw3-dev qt4-qmake libpulse-dev libx11-dev python-pkg-resources bc



#Configure blacklist
BLACKLIST_PATH=/etc/modprobe.d/blacklist.conf
if [ -a /etc/modprobe.d/raspi-blacklist.conf ]
then
    BLACKLIST_PATH=/etc/modprobe.d/raspi-blacklist.conf
fi
echo "**** Blacklisting TV tuner driver at $BLACKLIST_PATH ****"

echo 'blacklist dvb_usb_rtl28xxu
blacklist rtl_2832
blacklist rtl_2830' >> $BLACKLIST_PATH





#Create RTL-SDR directory
mkdir $RTL_BUILD_DIR



#Build new driver
echo '**** Fetching RTL-SDR driver module ****'
cd $RTL_BUILD_DIR
git clone git://git.osmocom.org/rtl-sdr.git
cd rtl-sdr
mkdir build
cd build
echo '**** Building RTL-SDR driver module ****'
cmake .. -DINSTALL_UDEV_RULES=ON
make
echo '**** Installing RTL-SDR driver module ****'
make install
ldconfig



#Install Kalibrate-RTL
echo '**** Fetching Kalibrate-RTL ****'
cd $RTL_BUILD_DIR
git clone https://github.com/asdil12/kalibrate-rtl.git
cd kalibrate-rtl
git checkout arm_memory
echo '**** Building Kalibrate-RTL ****'
./bootstrap
./configure
make
echo '**** Installing Kalibrate-RTL ****'
make install


echo "Done."
echo ""
echo "NOTE: For changes to take effect you should reboot your system.
echo ""
