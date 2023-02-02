#!/bin/bash

# Source Vars
source $CONFIG

# Change to the Home Directory
ls
cd ~/

# A Function to Send Posts to Telegram
telegram_message() {
	curl -s -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
	-d chat_id="${TG_CHAT_ID}" \
	-d parse_mode="HTML" \
	-d text="$1"
}

# Change to the Source Directory
cd $SYNC_PATH

# Clone the Sync Repo
repo init https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1

# Sync the Sources
repo sync || { echo "ERROR: Failed to Sync TWRP Sources!" && exit 1; }

# Install libcrypt
sudo apt-get install libcrypt-dev

# Clone gcc
git clone https://github.com/mvaisakh/gcc-arm.git prebuilts/gcc/linux-x86/arm/arm-eabi --depth=1 || { echo "ERROR: Failed to clone gcc-arm repo!" && exit 1; }
git clone https://github.com/mvaisakh/gcc-arm64.git prebuilts/gcc/linux-x86/aarch64/aarch64-elf --depth=1 || { echo "ERROR: Failed to clone gcc-arm64 repo!" && exit 1; }

# Clone Trees
git clone $DT_LINK $DT_PATH || { echo "ERROR: Failed to Clone the Device Trees!" && exit 1; }

# Clone the Kernel Sources
# only if the Kernel Source is Specified in the Config
[ ! -z "$KERNEL_SOURCE" ] && git clone --depth=1 --single-branch $KERNEL_SOURCE $KERNEL_PATH

# Exit
exit 0
