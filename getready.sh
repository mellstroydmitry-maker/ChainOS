#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Updating package lists ==="
sudo apt update

echo "=== Installing ADB, Fastboot, and system utilities ==="
sudo apt install -y android-tools-adb android-tools-fastboot \
    git curl wget unzip zip tar build-essential libssl-dev \
    pkg-config libusb-1.0-0-dev

echo "=== Setting up udev rules for Android devices ==="
# Downloading universal udev rules so the system recognizes the phone in ADB and Fastboot modes without sudo
sudo wget -O /etc/udev/rules.d/51-android.rules https://githubusercontent.com

echo "=== Setting correct permissions on udev rules ==="
sudo chmod a+r /etc/udev/rules.d/51-android.rules

echo "=== Adding current user to the plugdev group ==="
sudo usermod -aG plugdev $USER

echo "=== Restarting the udev service ==="
sudo udevadm control --reload-rules
sudo service udev restart

echo "========================================================="
echo " Everything is ready! Installed utility versions:"
adb --version
fastboot --version
echo "========================================================="
echo "IMPORTANT: To apply group changes, restart your PC"
echo "or run the following command: newgrp plugdev"
echo "========================================================="
