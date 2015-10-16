#!/bin/bash

# Colorize and add text parameters
grn=$(tput setaf 2)             #  green
txtbld=$(tput bold)             # Bold
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
txtrst=$(tput sgr0)             # Reset

DEVICE="$1"
THREADS="$2"
CLEAN="$3"

# Time of build startup
res1=$(date +%s.%N)

# Setup environment
echo -e "${bldblu}Setting up build environment ${txtrst}"
. build/envsetup.sh

# Setup ccache
export USE_CCACHE=1
export CCACHE_DIR="/home/travis/android/source/ccache"
/usr/bin/ccache -M 20G

# For building recovery
# export BUILDING_RECOVERY=false

# Prebuilt chromium
# export USE_PREBUILT_CHROMIUM=1

# Fix common out folder not being a common
#export ANDROID_FIXUP_COMMON_OUT=true

# Lunch device
echo -e "${bldblu}Lunching device... ${txtrst}"
lunch "tesla_$DEVICE-user"

# Clean out folder
if [ "$CLEAN" == "clean" ]
then
  echo -e "${bldblu}Cleaning up the OUT folder with make clobber ${txtrst}"
  make clobber;
else
  echo -e "${bldblu}No make clobber so just make installclean ${txtrst}"
  make installclean;
fi

# Remove previous build info
echo -e "${bldblu}Removing previous build.prop ${txtrst}"
rm $OUT/system/build.prop;

# Start compilation
echo -e "${bldblu}Starting build for $DEVICE ${txtrst}"
mka tesla -j"$THREADS";

# Get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
