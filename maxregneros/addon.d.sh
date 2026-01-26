#!/sbin/sh
############################################
# maxregnerOS addon.d survival script
# Based on Magisk addon.d script
############################################

. /tmp/backuptool.functions

list_files() {
cat <<EOF
data/maxregneros
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/"$FILE"
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/"$FILE" "$R"
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    # Stub
  ;;
  post-restore)
    # Recreate maxregnerOS environment
    if [ -d /data/maxregneros ]; then
      # Restore init.d scripts
      if [ -d /data/maxregneros/init.d ]; then
        chmod 755 /data/maxregneros/init.d/*.sh
      fi
      
      # Restore overlay permissions
      if [ -d /data/maxregneros/overlay ]; then
        chcon -R u:object_r:system_file:s0 /data/maxregneros/overlay/system 2>/dev/null
        chcon -R u:object_r:vendor_file:s0 /data/maxregneros/overlay/vendor 2>/dev/null
        chcon -R u:object_r:system_file:s0 /data/maxregneros/overlay/product 2>/dev/null
      fi
    fi
  ;;
esac
