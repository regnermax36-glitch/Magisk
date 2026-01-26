#!/system/bin/sh
############################################
# maxregnerOS Uninstaller Script
# Removes maxregnerOS modifications and restores original system
############################################

##############
# Preparation
##############

# Default permissions
umask 022

OUTFD=$2
COMMONDIR=$INSTALLER/assets

if [ ! -f $COMMONDIR/util_functions.sh ]; then
  echo "! Unable to extract zip file!"
  exit 1
fi

# Load utility functions
. $COMMONDIR/util_functions.sh
. $INSTALLER/maxregneros/maxregneros_functions.sh

setup_flashable

############
# Detection
############

print_title "maxregnerOS Uninstaller"

ui_print "- Checking for maxregnerOS installation"

if ! check_maxregneros_status; then
  ui_print "! maxregnerOS is not installed"
  ui_print "! Nothing to uninstall"
  exit 1
fi

ui_print "- maxregnerOS installation detected"

# Check device compatibility
DEVICE_MODEL=$(getprop ro.product.model)
DEVICE_CODENAME=$(getprop ro.product.device)

ui_print "- Device Model: $DEVICE_MODEL"
ui_print "- Device Codename: $DEVICE_CODENAME"

is_mounted /data || mount /data || is_mounted /cache || mount /cache
mount_partitions

##############
# Uninstallation
##############

ui_print "- Starting maxregnerOS uninstallation"

# Unmount overlay filesystems
ui_print "- Unmounting overlay filesystems"
umount /system 2>/dev/null
umount /vendor 2>/dev/null  
umount /product 2>/dev/null

# Remove maxregnerOS directories
ui_print "- Removing maxregnerOS files"
rm -rf /data/maxregneros

# Remove addon.d script
if [ -f /system/addon.d/99-maxregneros.sh ]; then
  ui_print "- Removing addon.d survival script"
  blockdev --setrw /dev/block/mapper/system$SLOT 2>/dev/null
  mount -o rw,remount /system || mount -o rw,remount /
  rm -f /system/addon.d/99-maxregneros.sh
fi

# Restore original system files if backup exists
if [ -d /data/maxregneros/backup ]; then
  ui_print "- Restoring original system files"
  restore_original_system
fi

# Clean up any remaining traces
ui_print "- Cleaning up remaining traces"
resetprop --delete ro.maxregneros.version 2>/dev/null
resetprop --delete ro.maxregneros.codename 2>/dev/null
resetprop --delete ro.maxregneros.device 2>/dev/null
resetprop --delete ro.maxregneros.build.date 2>/dev/null
resetprop --delete ro.maxregneros.build.type 2>/dev/null

# Restore original build.prop if modified
if [ -f /data/maxregneros/backup/build.prop.bak ]; then
  ui_print "- Restoring original build.prop"
  mount -o rw,remount /system || mount -o rw,remount /
  cp /data/maxregneros/backup/build.prop.bak /system/build.prop
  chmod 644 /system/build.prop
fi

# Final cleanup
rm -rf /data/maxregneros

ui_print "- maxregnerOS has been completely removed"
ui_print "- Your device has been restored to its original state"
ui_print "- Reboot to complete the uninstallation"

exit 0
