#!/system/bin/sh

#######################################################################################
# maxregnerOS Core Functions
# Advanced system management and installation utilities
#######################################################################################
#
# This file contains core functions for maxregnerOS system management,
# Samsung Galaxy Z Flip5 A/B support, and advanced filesystem operations.
#
#######################################################################################

###################
# Global Variables
###################

MAXREGNER_VERSION="2.0.0"
MAXREGNER_CODENAME="FlipOS"
MAXREGNER_BUILD_DATE="$(date '+%Y%m%d')"

# Filesystem paths
MAXREGNER_ROOT="/data/adb/maxregner"
MAXREGNER_SYSTEM="$MAXREGNER_ROOT/system"
MAXREGNER_CONFIG="$MAXREGNER_ROOT/config"
MAXREGNER_MODULES="$MAXREGNER_ROOT/modules"
MAXREGNER_CACHE="$MAXREGNER_ROOT/cache"
MAXREGNER_LOGS="$MAXREGNER_ROOT/logs"

# Samsung Galaxy Z Flip5 specific
SAMSUNG_ZFLIP5_PARTITIONS="boot recovery dtbo vbmeta vendor product system system_ext odm"
SAMSUNG_SECURITY_PARTITIONS="keystorage efs persist"

###################
# Utility Functions
###################

# Enhanced logging system
maxregner_log() {
  local level="$1"
  local message="$2"
  local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  
  echo "[$timestamp] [$level] $message" >> "$MAXREGNER_LOGS/system.log"
  
  case "$level" in
    "ERROR")
      ui_print "! ERROR: $message"
      ;;
    "WARN")
      ui_print "* WARNING: $message"
      ;;
    "INFO")
      ui_print "- $message"
      ;;
    "DEBUG")
      [ "$MAXREGNER_DEBUG" = "true" ] && ui_print "# DEBUG: $message"
      ;;
  esac
}

# System information gathering
get_system_info() {
  maxregner_log "INFO" "Gathering system information"
  
  # Basic device info
  DEVICE_CODENAME=$(getprop ro.product.device)
  DEVICE_MODEL=$(getprop ro.product.model)
  DEVICE_BRAND=$(getprop ro.product.brand)
  ANDROID_VERSION=$(getprop ro.build.version.release)
  SDK_VERSION=$(getprop ro.build.version.sdk)
  SECURITY_PATCH=$(getprop ro.build.version.security_patch)
  
  # Hardware info
  CPU_ABI=$(getprop ro.product.cpu.abi)
  CPU_ABI2=$(getprop ro.product.cpu.abi2)
  HARDWARE=$(getprop ro.hardware)
  
  # Samsung specific
  SAMSUNG_PLATFORM=$(getprop ro.hardware.chipset)
  ONEUI_VERSION=$(getprop ro.build.PDA)
  
  maxregner_log "INFO" "Device: $DEVICE_BRAND $DEVICE_MODEL ($DEVICE_CODENAME)"
  maxregner_log "INFO" "Android: $ANDROID_VERSION (SDK $SDK_VERSION)"
  maxregner_log "INFO" "Security patch: $SECURITY_PATCH"
  maxregner_log "INFO" "CPU: $CPU_ABI"
}

# Advanced A/B partition management
detect_ab_system() {
  maxregner_log "INFO" "Detecting A/B partition system"
  
  # Check for A/B support in multiple ways
  AB_SUPPORTED=false
  
  # Method 1: Check cmdline
  if grep -q "androidboot.slot_suffix" /proc/cmdline; then
    AB_SUPPORTED=true
    CURRENT_SLOT=$(grep -o 'androidboot.slot_suffix=[^[:space:]]*' /proc/cmdline | cut -d= -f2)
  elif grep -q "androidboot.slot" /proc/cmdline; then
    AB_SUPPORTED=true
    CURRENT_SLOT="_$(grep -o 'androidboot.slot=[^[:space:]]*' /proc/cmdline | cut -d= -f2)"
  fi
  
  # Method 2: Check for A/B partitions
  if [ "$AB_SUPPORTED" = "false" ]; then
    if [ -e "/dev/block/by-name/boot_a" ] && [ -e "/dev/block/by-name/boot_b" ]; then
      AB_SUPPORTED=true
      # Determine current slot by checking which boot partition is active
      if [ -e "/dev/block/by-name/boot" ]; then
        BOOT_LINK=$(readlink /dev/block/by-name/boot)
        if echo "$BOOT_LINK" | grep -q "_a"; then
          CURRENT_SLOT="_a"
        elif echo "$BOOT_LINK" | grep -q "_b"; then
          CURRENT_SLOT="_b"
        fi
      fi
    fi
  fi
  
  if [ "$AB_SUPPORTED" = "true" ]; then
    maxregner_log "INFO" "A/B device detected"
    maxregner_log "INFO" "Current slot: $CURRENT_SLOT"
    
    # Determine inactive slot
    if [ "$CURRENT_SLOT" = "_a" ]; then
      INACTIVE_SLOT="_b"
    else
      INACTIVE_SLOT="_a"
    fi
    maxregner_log "INFO" "Inactive slot: $INACTIVE_SLOT"
    
    # Export variables
    export AB_SUPPORTED CURRENT_SLOT INACTIVE_SLOT
  else
    maxregner_log "INFO" "Non-A/B device detected"
    export AB_SUPPORTED
  fi
}

# Samsung Galaxy Z Flip5 specific functions
setup_samsung_zflip5() {
  maxregner_log "INFO" "Setting up Samsung Galaxy Z Flip5 support"
  
  # Verify device
  if [ "$DEVICE_CODENAME" != "b5q" ] && [ "$DEVICE_MODEL" != "SM-F731B" ] && [ "$DEVICE_MODEL" != "SM-F731U" ]; then
    maxregner_log "WARN" "Device is not Samsung Galaxy Z Flip5, skipping specific optimizations"
    return 1
  fi
  
  # Samsung-specific partition detection
  maxregner_log "INFO" "Detecting Samsung partitions"
  for partition in $SAMSUNG_ZFLIP5_PARTITIONS; do
    if [ "$AB_SUPPORTED" = "true" ]; then
      if [ -e "/dev/block/by-name/${partition}${CURRENT_SLOT}" ]; then
        maxregner_log "INFO" "Found ${partition}${CURRENT_SLOT}"
      fi
      if [ -e "/dev/block/by-name/${partition}${INACTIVE_SLOT}" ]; then
        maxregner_log "INFO" "Found ${partition}${INACTIVE_SLOT}"
      fi
    else
      if [ -e "/dev/block/by-name/${partition}" ]; then
        maxregner_log "INFO" "Found ${partition}"
      fi
    fi
  done
  
  # Check Samsung security partitions
  for partition in $SAMSUNG_SECURITY_PARTITIONS; do
    if [ -e "/dev/block/by-name/${partition}" ]; then
      maxregner_log "INFO" "Found security partition: ${partition}"
    fi
  done
  
  # Samsung-specific configurations
  setup_samsung_security_bypass
  setup_samsung_knox_bypass
  
  maxregner_log "INFO" "Samsung Galaxy Z Flip5 setup complete"
}

# Samsung security bypass
setup_samsung_security_bypass() {
  maxregner_log "INFO" "Setting up Samsung security bypass"
  
  # Create security bypass configuration
  cat > "$MAXREGNER_CONFIG/samsung_security.conf" << EOF
# Samsung Security Bypass Configuration
# Generated for Samsung Galaxy Z Flip5

[security]
knox_bypass=true
defex_bypass=true
proca_bypass=true
rkp_bypass=true
dm_verity_bypass=true

[partitions]
vbmeta_patch=true
boot_patch=true
recovery_patch=true

[features]
root_hiding=true
safetynet_bypass=true
magisk_hide=true
EOF

  maxregner_log "INFO" "Samsung security bypass configured"
}

# Samsung KNOX bypass
setup_samsung_knox_bypass() {
  maxregner_log "INFO" "Setting up Samsung KNOX bypass"
  
  # KNOX bypass script
  cat > "$MAXREGNER_SYSTEM/knox_bypass.sh" << 'EOF'
#!/system/bin/sh
# Samsung KNOX Bypass Script

# Disable KNOX services
setprop ro.config.knox disabled
setprop ro.config.dmverity false
setprop ro.config.kap_default_on false

# Patch KNOX-related properties
resetprop ro.boot.warranty_bit 0
resetprop ro.warranty_bit 0
resetprop ro.debuggable 1
resetprop ro.secure 0

# Disable KNOX containers
pm disable com.samsung.android.knox.containercore
pm disable com.samsung.android.knox.containeragent
pm disable com.samsung.android.knox.kpecore

echo "KNOX bypass applied"
EOF

  chmod 755 "$MAXREGNER_SYSTEM/knox_bypass.sh"
  maxregner_log "INFO" "KNOX bypass script created"
}

# Advanced filesystem operations
create_maxregner_overlay() {
  maxregner_log "INFO" "Creating maxregnerOS filesystem overlay"
  
  # Create overlay directories
  OVERLAY_DIRS="system vendor product system_ext odm"
  
  for dir in $OVERLAY_DIRS; do
    mkdir -p "$MAXREGNER_SYSTEM/overlay/$dir"
    maxregner_log "INFO" "Created overlay directory: $dir"
  done
  
  # Create overlay mount script
  cat > "$MAXREGNER_SYSTEM/overlay_mount.sh" << 'EOF'
#!/system/bin/sh
# maxregnerOS Overlay Mount Script

OVERLAY_ROOT="/data/adb/maxregner/system/overlay"

mount_overlay() {
  local target="$1"
  local overlay="$OVERLAY_ROOT/$target"
  
  if [ -d "$overlay" ] && [ "$(ls -A "$overlay" 2>/dev/null)" ]; then
    echo "Mounting overlay for /$target"
    mount -t overlay overlay -o lowerdir=/$target,upperdir=$overlay,workdir=/tmp/overlay_work_$target /$target
  fi
}

# Mount overlays
for dir in system vendor product system_ext odm; do
  mount_overlay "$dir"
done
EOF

  chmod 755 "$MAXREGNER_SYSTEM/overlay_mount.sh"
  maxregner_log "INFO" "Overlay mount script created"
}

# Module management system
setup_module_system() {
  maxregner_log "INFO" "Setting up maxregnerOS module system"
  
  # Create module directories
  mkdir -p "$MAXREGNER_MODULES/enabled"
  mkdir -p "$MAXREGNER_MODULES/disabled"
  mkdir -p "$MAXREGNER_MODULES/cache"
  
  # Module manager script
  cat > "$MAXREGNER_SYSTEM/module_manager.sh" << 'EOF'
#!/system/bin/sh
# maxregnerOS Module Manager

MODULE_ROOT="/data/adb/maxregner/modules"

load_modules() {
  echo "Loading maxregnerOS modules..."
  
  for module in "$MODULE_ROOT/enabled"/*; do
    if [ -d "$module" ] && [ -f "$module/module.prop" ]; then
      module_name=$(basename "$module")
      echo "Loading module: $module_name"
      
      # Source module configuration
      . "$module/module.prop"
      
      # Execute module script if exists
      if [ -f "$module/service.sh" ]; then
        sh "$module/service.sh"
      fi
    fi
  done
}

# Load modules on boot
load_modules
EOF

  chmod 755 "$MAXREGNER_SYSTEM/module_manager.sh"
  maxregner_log "INFO" "Module system configured"
}

# Boot integration
setup_boot_integration() {
  maxregner_log "INFO" "Setting up boot integration"
  
  # Create boot script
  cat > "$MAXREGNER_SYSTEM/boot.sh" << 'EOF'
#!/system/bin/sh
# maxregnerOS Boot Script

MAXREGNER_ROOT="/data/adb/maxregner"
LOG_FILE="$MAXREGNER_ROOT/logs/boot.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log "maxregnerOS boot sequence starting"

# Load system configuration
if [ -f "$MAXREGNER_ROOT/config/system.conf" ]; then
  . "$MAXREGNER_ROOT/config/system.conf"
  log "System configuration loaded"
fi

# Apply Samsung-specific configurations
if [ -f "$MAXREGNER_ROOT/system/knox_bypass.sh" ]; then
  sh "$MAXREGNER_ROOT/system/knox_bypass.sh"
  log "Samsung KNOX bypass applied"
fi

# Mount filesystem overlays
if [ -f "$MAXREGNER_ROOT/system/overlay_mount.sh" ]; then
  sh "$MAXREGNER_ROOT/system/overlay_mount.sh"
  log "Filesystem overlays mounted"
fi

# Load modules
if [ -f "$MAXREGNER_ROOT/system/module_manager.sh" ]; then
  sh "$MAXREGNER_ROOT/system/module_manager.sh"
  log "Modules loaded"
fi

log "maxregnerOS boot sequence complete"
EOF

  chmod 755 "$MAXREGNER_SYSTEM/boot.sh"
  maxregner_log "INFO" "Boot integration configured"
}

# System verification
verify_maxregner_system() {
  maxregner_log "INFO" "Verifying maxregnerOS system integrity"
  
  local errors=0
  
  # Check required directories
  for dir in "$MAXREGNER_ROOT" "$MAXREGNER_SYSTEM" "$MAXREGNER_CONFIG" "$MAXREGNER_MODULES" "$MAXREGNER_CACHE" "$MAXREGNER_LOGS"; do
    if [ ! -d "$dir" ]; then
      maxregner_log "ERROR" "Missing directory: $dir"
      errors=$((errors + 1))
    fi
  done
  
  # Check required files
  REQUIRED_FILES="$MAXREGNER_CONFIG/system.conf $MAXREGNER_SYSTEM/boot.sh"
  for file in $REQUIRED_FILES; do
    if [ ! -f "$file" ]; then
      maxregner_log "ERROR" "Missing file: $file"
      errors=$((errors + 1))
    fi
  done
  
  # Check permissions
  if [ "$(stat -c %a "$MAXREGNER_CONFIG")" != "700" ]; then
    maxregner_log "ERROR" "Incorrect permissions on config directory"
    errors=$((errors + 1))
  fi
  
  if [ "$errors" -eq 0 ]; then
    maxregner_log "INFO" "System verification passed"
    return 0
  else
    maxregner_log "ERROR" "System verification failed with $errors errors"
    return 1
  fi
}

# Cleanup function
cleanup_maxregner() {
  maxregner_log "INFO" "Cleaning up maxregnerOS installation"
  
  # Remove temporary files
  rm -rf /tmp/maxregner_*
  
  # Clean cache
  rm -rf "$MAXREGNER_CACHE"/*
  
  maxregner_log "INFO" "Cleanup complete"
}

# Main initialization function
init_maxregner_system() {
  maxregner_log "INFO" "Initializing maxregnerOS system"
  
  # Create log directory
  mkdir -p "$MAXREGNER_LOGS"
  
  # Gather system information
  get_system_info
  
  # Detect A/B system
  detect_ab_system
  
  # Setup Samsung Z Flip5 if applicable
  if [ "$DEVICE_CODENAME" = "b5q" ] || [ "$DEVICE_MODEL" = "SM-F731B" ] || [ "$DEVICE_MODEL" = "SM-F731U" ]; then
    setup_samsung_zflip5
  fi
  
  # Create filesystem overlay
  create_maxregner_overlay
  
  # Setup module system
  setup_module_system
  
  # Setup boot integration
  setup_boot_integration
  
  # Verify system
  if verify_maxregner_system; then
    maxregner_log "INFO" "maxregnerOS system initialization complete"
    return 0
  else
    maxregner_log "ERROR" "maxregnerOS system initialization failed"
    return 1
  fi
}

###################
# Export Functions
###################

# Make functions available to other scripts
export -f maxregner_log
export -f get_system_info
export -f detect_ab_system
export -f setup_samsung_zflip5
export -f create_maxregner_overlay
export -f setup_module_system
export -f verify_maxregner_system
export -f init_maxregner_system
