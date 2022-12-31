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

# Clone the Sync Repo
git clone $TW_SYNC
cd sync

# Setup the Sync Branch
if [ -z "$SYNC_BRANCH" ]; then
    export SYNC_BRANCH=$(echo ${TW_BRANCH} | cut -d_ -f2)
fi

# Sync the Sources
repo sync --branch $SYNC_BRANCH --path $SYNC_PATH || { echo "ERROR: Failed to Sync TWRP Sources!" && exit 1; }

# Install libcrypt
sudo apt-get install libcrypt-dev

# Change to the Source Directory
cd $SYNC_PATH

# Clone gcc
git clone https://github.com/mvaisakh/gcc-arm.git prebuilts/gcc/linux-x86/arm/arm-eabi || { echo "ERROR: Failed to clone gcc-arm repo!" && exit 1; }
git clone https://github.com/mvaisakh/gcc-arm64.git prebuilts/gcc/linux-x86/aarch64/aarch64-elf || { echo "ERROR: Failed to clone gcc-arm64 repo!" && exit 1; }

# Clone Trees
git clone $DT_LINK $DT_PATH || { echo "ERROR: Failed to Clone the Device Trees!" && exit 1; }

# Clone the Kernel Sources
# only if the Kernel Source is Specified in the Config
[ ! -z "$KERNEL_SOURCE" ] && git clone --depth=1 --single-branch $KERNEL_SOURCE $KERNEL_PATH

# Exit
exit 0
