#!/system/bin/sh
############################################
# maxregnerOS Installer Script
# Based on Magisk Flash Script
# Custom OS redesigner for Samsung Galaxy Z Flip5
############################################

##############
# Preparation
##############

# Default permissions
umask 022

OUTFD=$2
COMMONDIR=$INSTALLER/assets
MAXREGNEROS_DIR=$INSTALLER/maxregneros

if [ ! -f $COMMONDIR/util_functions.sh ]; then
  echo "! Unable to extract zip file!"
  exit 1
fi

# Load utility functions
. $COMMONDIR/util_functions.sh

setup_flashable

############
# Detection
############

MAXREGNEROS_VER="1.0.0"
MAXREGNEROS_VER_CODE="100"

print_title "maxregnerOS $MAXREGNEROS_VER Installer for Samsung Galaxy Z Flip5"

# Check device compatibility
DEVICE_MODEL=$(getprop ro.product.model)
DEVICE_CODENAME=$(getprop ro.product.device)

ui_print "- Device Model: $DEVICE_MODEL"
ui_print "- Device Codename: $DEVICE_CODENAME"

# Verify Z Flip5 compatibility
if [ "$DEVICE_CODENAME" != "b0q" ] && [ "$DEVICE_CODENAME" != "gts9" ] && [ "$DEVICE_MODEL" != "SM-F731*" ]; then
  ui_print "! Warning: This installer is optimized for Samsung Galaxy Z Flip5"
  ui_print "! Proceeding anyway, but compatibility is not guaranteed"
fi

is_mounted /data || mount /data || is_mounted /cache || mount /cache
mount_partitions
check_data
get_flags
find_boot_image

[ -z $BOOTIMAGE ] && abort "! Unable to detect target image"
ui_print "- Target image: $BOOTIMAGE"

# Detect version and architecture
api_level_arch_detect

[ $API -lt 29 ] && abort "! maxregnerOS requires Android 10.0 and above"

ui_print "- Device platform: $ABI"
ui_print "- Android API: $API"

BINDIR=$INSTALLER/lib/$ABI
cd $BINDIR
for file in lib*.so; do mv "$file" "${file:3:${#file}-6}"; done
cd /
cp -af $INSTALLER/lib/$ABI32/libmagisk.so $BINDIR/magisk32 2>/dev/null

# Check if system root is installed and remove
$BOOTMODE || remove_system_su

##############
# Environment
##############

ui_print "- Constructing maxregnerOS environment"

# Copy required files
rm -rf $MAGISKBIN 2>/dev/null
mkdir -p $MAGISKBIN 2>/dev/null
cp -af $BINDIR/. $COMMONDIR/. $BBBIN $MAGISKBIN

# Copy maxregnerOS specific files
cp -af $MAXREGNEROS_DIR/. $MAGISKBIN/

# Remove files only used by the Magisk app
rm -f $MAGISKBIN/bootctl $MAGISKBIN/main.jar \
  $MAGISKBIN/module_installer.sh $MAGISKBIN/uninstaller.sh

chmod -R 755 $MAGISKBIN

# addon.d
if [ -d /system/addon.d ]; then
  ui_print "- Adding maxregnerOS addon.d survival script"
  blockdev --setrw /dev/block/mapper/system$SLOT 2>/dev/null
  mount -o rw,remount /system || mount -o rw,remount /
  ADDOND=/system/addon.d/99-maxregneros.sh
  cp -af $MAXREGNEROS_DIR/addon.d.sh $ADDOND
  chmod 755 $ADDOND
fi

##################
# maxregnerOS Installation
##################

ui_print "- Installing maxregnerOS filesystem restructure"
install_maxregneros_filesystem

ui_print "- Installing maxregnerOS UI components"
install_maxregneros_ui

ui_print "- Patching boot image with maxregnerOS modifications"
install_magisk

# maxregnerOS specific post-install
ui_print "- Applying maxregnerOS system tweaks"
apply_maxregneros_tweaks

# Cleanups
$BOOTMODE || recovery_cleanup
rm -rf $TMPDIR

ui_print "- maxregnerOS installation completed successfully!"
ui_print "- Reboot to experience your new maxregnerOS"
exit 0
