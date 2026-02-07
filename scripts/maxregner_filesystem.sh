#!/system/bin/sh

#######################################################################################
# maxregnerOS Filesystem Manager
# Advanced filesystem operations and overlay management
#######################################################################################
#
# This script provides comprehensive filesystem management including:
# - Overlay filesystem creation and management
# - System partition modifications
# - File system optimization
# - Samsung-specific filesystem handling
#
#######################################################################################

###################
# Global Variables
###################

FILESYSTEM_VERSION="2.0.0"
LOG_FILE="/data/adb/maxregner/logs/filesystem.log"

# maxregnerOS filesystem structure
MAXREGNER_ROOT="/data/adb/maxregner"
MAXREGNER_SYSTEM="$MAXREGNER_ROOT/system"
MAXREGNER_OVERLAYS="$MAXREGNER_SYSTEM/overlays"
MAXREGNER_MOUNTS="$MAXREGNER_ROOT/mounts"

# System partitions to manage
SYSTEM_PARTITIONS="system vendor product system_ext odm"
OVERLAY_WORK_DIR="/data/adb/maxregner/overlay_work"

###################
# Logging Functions
###################

fs_log() {
  local level="$1"
  local message="$2"
  local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  
  echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
  echo "[$level] $message"
}

###################
# Filesystem Detection
###################

detect_filesystem_support() {
  fs_log "INFO" "Detecting filesystem support"
  
  # Check for overlay filesystem support
  OVERLAY_SUPPORTED=false
  if grep -q "overlay" /proc/filesystems; then
    OVERLAY_SUPPORTED=true
    fs_log "INFO" "Overlay filesystem supported"
  else
    fs_log "WARN" "Overlay filesystem not supported"
  fi
  
  # Check for bind mount support
  BIND_MOUNT_SUPPORTED=true
  fs_log "INFO" "Bind mount support available"
  
  # Check available space
  AVAILABLE_SPACE=$(df /data | tail -1 | awk '{print $4}')
  fs_log "INFO" "Available space in /data: ${AVAILABLE_SPACE}KB"
  
  export OVERLAY_SUPPORTED BIND_MOUNT_SUPPORTED AVAILABLE_SPACE
}

detect_system_partitions() {
  fs_log "INFO" "Detecting system partitions"
  
  DETECTED_PARTITIONS=""
  
  for partition in $SYSTEM_PARTITIONS; do
    if [ -d "/$partition" ]; then
      DETECTED_PARTITIONS="$DETECTED_PARTITIONS $partition"
      fs_log "INFO" "Found partition: /$partition"
      
      # Check if partition is writable
      if touch "/$partition/.maxregner_test" 2>/dev/null; then
        rm -f "/$partition/.maxregner_test"
        fs_log "INFO" "Partition /$partition is writable"
      else
        fs_log "INFO" "Partition /$partition is read-only"
      fi
    fi
  done
  
  export DETECTED_PARTITIONS
}

###################
# Overlay Management
###################

create_overlay_structure() {
  fs_log "INFO" "Creating overlay filesystem structure"
  
  # Create base directories
  mkdir -p "$MAXREGNER_OVERLAYS"
  mkdir -p "$OVERLAY_WORK_DIR"
  mkdir -p "$MAXREGNER_MOUNTS"
  
  # Create overlay directories for each partition
  for partition in $DETECTED_PARTITIONS; do
    local overlay_dir="$MAXREGNER_OVERLAYS/$partition"
    local work_dir="$OVERLAY_WORK_DIR/$partition"
    
    mkdir -p "$overlay_dir/upper"
    mkdir -p "$overlay_dir/work"
    mkdir -p "$work_dir"
    
    fs_log "INFO" "Created overlay structure for /$partition"
  done
  
  # Set proper permissions
  chmod 755 "$MAXREGNER_OVERLAYS"
  chmod 755 "$OVERLAY_WORK_DIR"
  
  fs_log "INFO" "Overlay structure created"
}

mount_overlay_filesystem() {
  local partition="$1"
  
  fs_log "INFO" "Mounting overlay for /$partition"
  
  if [ "$OVERLAY_SUPPORTED" != "true" ]; then
    fs_log "ERROR" "Overlay filesystem not supported"
    return 1
  fi
  
  local overlay_dir="$MAXREGNER_OVERLAYS/$partition"
  local upper_dir="$overlay_dir/upper"
  local work_dir="$overlay_dir/work"
  local mount_point="/$partition"
  
  # Check if already mounted
  if mount | grep -q "overlay.*$mount_point"; then
    fs_log "WARN" "Overlay already mounted for /$partition"
    return 0
  fi
  
  # Create mount point backup
  local backup_dir="$MAXREGNER_MOUNTS/${partition}_original"
  if [ ! -d "$backup_dir" ]; then
    mkdir -p "$backup_dir"
    # Create bind mount to preserve original
    mount --bind "$mount_point" "$backup_dir"
    fs_log "INFO" "Created backup mount for /$partition"
  fi
  
  # Mount overlay
  if mount -t overlay overlay \
    -o lowerdir="$mount_point",upperdir="$upper_dir",workdir="$work_dir" \
    "$mount_point"; then
    fs_log "INFO" "Successfully mounted overlay for /$partition"
    return 0
  else
    fs_log "ERROR" "Failed to mount overlay for /$partition"
    return 1
  fi
}

unmount_overlay_filesystem() {
  local partition="$1"
  
  fs_log "INFO" "Unmounting overlay for /$partition"
  
  local mount_point="/$partition"
  local backup_dir="$MAXREGNER_MOUNTS/${partition}_original"
  
  # Unmount overlay
  if umount "$mount_point"; then
    fs_log "INFO" "Unmounted overlay for /$partition"
    
    # Restore original if backup exists
    if [ -d "$backup_dir" ]; then
      umount "$backup_dir"
      rmdir "$backup_dir"
      fs_log "INFO" "Restored original mount for /$partition"
    fi
    
    return 0
  else
    fs_log "ERROR" "Failed to unmount overlay for /$partition"
    return 1
  fi
}

###################
# File Operations
###################

install_file_to_overlay() {
  local source_file="$1"
  local target_path="$2"
  local partition="$3"
  
  fs_log "INFO" "Installing file to overlay: $target_path"
  
  if [ ! -f "$source_file" ]; then
    fs_log "ERROR" "Source file not found: $source_file"
    return 1
  fi
  
  local overlay_dir="$MAXREGNER_OVERLAYS/$partition/upper"
  local target_dir="$(dirname "$target_path")"
  local full_target="$overlay_dir$target_path"
  
  # Create target directory structure
  mkdir -p "$overlay_dir$target_dir"
  
  # Copy file
  if cp "$source_file" "$full_target"; then
    # Set proper permissions
    chmod 644 "$full_target"
    fs_log "INFO" "File installed to overlay: $target_path"
    return 0
  else
    fs_log "ERROR" "Failed to install file: $target_path"
    return 1
  fi
}

remove_file_from_overlay() {
  local target_path="$1"
  local partition="$2"
  
  fs_log "INFO" "Removing file from overlay: $target_path"
  
  local overlay_dir="$MAXREGNER_OVERLAYS/$partition/upper"
  local full_target="$overlay_dir$target_path"
  
  if [ -f "$full_target" ]; then
    rm -f "$full_target"
    fs_log "INFO" "File removed from overlay: $target_path"
    return 0
  else
    fs_log "WARN" "File not found in overlay: $target_path"
    return 1
  fi
}

create_directory_in_overlay() {
  local target_path="$1"
  local partition="$2"
  
  fs_log "INFO" "Creating directory in overlay: $target_path"
  
  local overlay_dir="$MAXREGNER_OVERLAYS/$partition/upper"
  local full_target="$overlay_dir$target_path"
  
  if mkdir -p "$full_target"; then
    chmod 755 "$full_target"
    fs_log "INFO" "Directory created in overlay: $target_path"
    return 0
  else
    fs_log "ERROR" "Failed to create directory: $target_path"
    return 1
  fi
}

###################
# Samsung Specific
###################

setup_samsung_filesystem_optimizations() {
  fs_log "INFO" "Setting up Samsung filesystem optimizations"
  
  # Samsung-specific filesystem tweaks
  local samsung_optimizations="
# Samsung filesystem optimizations
echo 'deadline' > /sys/block/sda/queue/scheduler
echo '1024' > /sys/block/sda/queue/read_ahead_kb
echo '0' > /sys/block/sda/queue/add_random

# Samsung UFS optimizations
if [ -d /sys/class/scsi_host ]; then
  for host in /sys/class/scsi_host/host*; do
    echo 'deadline' > \$host/queue/scheduler 2>/dev/null || true
  done
fi
"
  
  # Create optimization script
  echo "$samsung_optimizations" > "$MAXREGNER_SYSTEM/samsung_fs_optimizations.sh"
  chmod 755 "$MAXREGNER_SYSTEM/samsung_fs_optimizations.sh"
  
  fs_log "INFO" "Samsung filesystem optimizations configured"
}

###################
# System Integration
###################

create_filesystem_service() {
  fs_log "INFO" "Creating filesystem service"
  
  cat > "$MAXREGNER_SYSTEM/filesystem_service.sh" << 'EOF'
#!/system/bin/sh
# maxregnerOS Filesystem Service

MAXREGNER_ROOT="/data/adb/maxregner"
LOG_FILE="$MAXREGNER_ROOT/logs/filesystem_service.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log "Filesystem service starting"

# Load filesystem manager
if [ -f "$MAXREGNER_ROOT/../scripts/maxregner_filesystem.sh" ]; then
  . "$MAXREGNER_ROOT/../scripts/maxregner_filesystem.sh"
  
  # Initialize filesystem
  detect_filesystem_support
  detect_system_partitions
  create_overlay_structure
  
  # Mount overlays for enabled partitions
  for partition in $DETECTED_PARTITIONS; do
    if [ -f "$MAXREGNER_ROOT/config/overlay_${partition}.enabled" ]; then
      mount_overlay_filesystem "$partition"
      log "Mounted overlay for /$partition"
    fi
  done
  
  log "Filesystem service initialized"
else
  log "ERROR: Filesystem manager not found"
fi

log "Filesystem service complete"
EOF

  chmod 755 "$MAXREGNER_SYSTEM/filesystem_service.sh"
  fs_log "INFO" "Filesystem service created"
}

###################
# Management Commands
###################

enable_overlay_for_partition() {
  local partition="$1"
  
  fs_log "INFO" "Enabling overlay for partition: $partition"
  
  if ! echo "$DETECTED_PARTITIONS" | grep -q "$partition"; then
    fs_log "ERROR" "Partition not found: $partition"
    return 1
  fi
  
  # Create enable flag
  touch "$MAXREGNER_ROOT/config/overlay_${partition}.enabled"
  
  # Mount overlay if not already mounted
  if ! mount | grep -q "overlay.*/$partition"; then
    mount_overlay_filesystem "$partition"
  fi
  
  fs_log "INFO" "Overlay enabled for partition: $partition"
}

disable_overlay_for_partition() {
  local partition="$1"
  
  fs_log "INFO" "Disabling overlay for partition: $partition"
  
  # Remove enable flag
  rm -f "$MAXREGNER_ROOT/config/overlay_${partition}.enabled"
  
  # Unmount overlay if mounted
  if mount | grep -q "overlay.*/$partition"; then
    unmount_overlay_filesystem "$partition"
  fi
  
  fs_log "INFO" "Overlay disabled for partition: $partition"
}

show_filesystem_status() {
  echo "=== maxregnerOS Filesystem Status ==="
  echo "Overlay Support: $OVERLAY_SUPPORTED"
  echo "Available Space: ${AVAILABLE_SPACE}KB"
  echo ""
  
  echo "=== Detected Partitions ==="
  for partition in $DETECTED_PARTITIONS; do
    printf "%-12s: " "$partition"
    
    if [ -f "$MAXREGNER_ROOT/config/overlay_${partition}.enabled" ]; then
      if mount | grep -q "overlay.*/$partition"; then
        echo "Enabled & Mounted"
      else
        echo "Enabled (Not Mounted)"
      fi
    else
      echo "Disabled"
    fi
  done
  
  echo ""
  echo "=== Overlay Usage ==="
  for partition in $DETECTED_PARTITIONS; do
    local overlay_dir="$MAXREGNER_OVERLAYS/$partition/upper"
    if [ -d "$overlay_dir" ]; then
      local usage=$(du -sh "$overlay_dir" 2>/dev/null | cut -f1)
      printf "%-12s: %s\n" "$partition" "$usage"
    fi
  done
}

###################
# Main Functions
###################

show_help() {
  echo "maxregnerOS Filesystem Manager v$FILESYSTEM_VERSION"
  echo ""
  echo "Usage: $0 [command] [options]"
  echo ""
  echo "Commands:"
  echo "  init                    - Initialize filesystem support"
  echo "  status                  - Show filesystem status"
  echo "  enable <partition>      - Enable overlay for partition"
  echo "  disable <partition>     - Disable overlay for partition"
  echo "  mount <partition>       - Mount overlay for partition"
  echo "  unmount <partition>     - Unmount overlay for partition"
  echo "  install <src> <dst> <part> - Install file to overlay"
  echo "  remove <path> <part>    - Remove file from overlay"
  echo "  optimize                - Apply filesystem optimizations"
  echo "  help                    - Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 init"
  echo "  $0 enable system"
  echo "  $0 install /sdcard/app.apk /system/app/MyApp.apk system"
}

main() {
  local command="$1"
  
  # Create log directory
  mkdir -p "$(dirname "$LOG_FILE")"
  
  fs_log "INFO" "maxregnerOS Filesystem Manager v$FILESYSTEM_VERSION starting"
  
  case "$command" in
    "init")
      detect_filesystem_support
      detect_system_partitions
      create_overlay_structure
      create_filesystem_service
      setup_samsung_filesystem_optimizations
      fs_log "INFO" "Filesystem initialization complete"
      ;;
    "status")
      detect_filesystem_support
      detect_system_partitions
      show_filesystem_status
      ;;
    "enable")
      local partition="$2"
      if [ -z "$partition" ]; then
        echo "Error: Please specify partition name"
        exit 1
      fi
      detect_filesystem_support
      detect_system_partitions
      enable_overlay_for_partition "$partition"
      ;;
    "disable")
      local partition="$2"
      if [ -z "$partition" ]; then
        echo "Error: Please specify partition name"
        exit 1
      fi
      detect_system_partitions
      disable_overlay_for_partition "$partition"
      ;;
    "mount")
      local partition="$2"
      if [ -z "$partition" ]; then
        echo "Error: Please specify partition name"
        exit 1
      fi
      detect_filesystem_support
      detect_system_partitions
      create_overlay_structure
      mount_overlay_filesystem "$partition"
      ;;
    "unmount")
      local partition="$2"
      if [ -z "$partition" ]; then
        echo "Error: Please specify partition name"
        exit 1
      fi
      unmount_overlay_filesystem "$partition"
      ;;
    "install")
      local source="$2"
      local target="$3"
      local partition="$4"
      if [ -z "$source" ] || [ -z "$target" ] || [ -z "$partition" ]; then
        echo "Error: Please specify source, target, and partition"
        exit 1
      fi
      install_file_to_overlay "$source" "$target" "$partition"
      ;;
    "remove")
      local target="$2"
      local partition="$3"
      if [ -z "$target" ] || [ -z "$partition" ]; then
        echo "Error: Please specify target path and partition"
        exit 1
      fi
      remove_file_from_overlay "$target" "$partition"
      ;;
    "optimize")
      setup_samsung_filesystem_optimizations
      ;;
    "help"|"")
      show_help
      ;;
    *)
      echo "Error: Unknown command '$command'"
      echo "Use '$0 help' for usage information"
      exit 1
      ;;
  esac
  
  fs_log "INFO" "maxregnerOS Filesystem Manager operation complete"
}

# Run main function with all arguments
main "$@"
