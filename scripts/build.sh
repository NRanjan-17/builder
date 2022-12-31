#!/bin/bash

# Source Configs
source $CONFIG

# A Function to Send Posts to Telegram
telegram_message() {
	curl -s -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
	-d chat_id="${TG_CHAT_ID}" \
	-d parse_mode="HTML" \
	-d text="$1"
}

# Change to the Source Directry
cd $SYNC_PATH

# Sync Branch (will be used to fix legacy build system errors)
if [ -z "$SYNC_BRANCH" ]; then
    export SYNC_BRANCH=$(echo ${TW_BRANCH} | cut -d_ -f2)
fi

# Set-up ccache
if [ -z "$CCACHE_SIZE" ]; then
    ccache -M 10G
else
    ccache -M ${CCACHE_SIZE}
fi

# Send the Telegram Message

echo -e \
"
TWRP Recovery CI

✔️ The Build has been Triggered!

📱 Device: "${DEVICE}"
🖥 Build System: "${TW_BRANCH}"
🌲 Logs: <a href=\"https://cirrus-ci.com/build/${CIRRUS_BUILD_ID}\">Here</a>
" > tg.html

TG_TEXT=$(< tg.html)

telegram_message "${TG_TEXT}"
echo " "

# Prepare the Build Environment
source build/envsetup.sh

# Run the Extra Command
$EXTRA_CMD

# export some Basic Vars
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"

# Set BRANCH_INT variable for future use
BRANCH_INT=$(echo $SYNC_BRANCH | cut -d. -f1)

# lunch the target
if [ "$BRANCH_INT" -ge 11 ]; then
    lunch twrp_${DEVICE}-eng || { echo "ERROR: Failed to lunch the target!" && exit 1; }
else
    lunch omni_${DEVICE}-eng || { echo "ERROR: Failed to lunch the target!" && exit 1; }
fi

# Build the Code
if [ -z "$J_VAL" ]; then
    mka -j$(nproc --all) $TARGET || { echo "ERROR: Failed to Build TWRP!" && exit 1; }
elif [ "$J_VAL"="0" ]; then
    mka $TARGET || { echo "ERROR: Failed to Build TWRP!" && exit 1; }
else
    mka -j${J_VAL} $TARGET || { echo "ERROR: Failed to Build TWRP!" && exit 1; }
fi

# Exit
exit 0
