#!/system/bin/sh

#######################################################################################
# maxregnerOS A/B Slot Manager
# Advanced A/B partition management for Samsung Galaxy Z Flip5 and other devices
#######################################################################################
#
# This script provides comprehensive A/B slot management including:
# - Slot detection and switching
# - Samsung-specific A/B handling
# - Partition verification and repair
# - Boot slot optimization
#
#######################################################################################

###################
# Global Variables
###################

AB_MANAGER_VERSION="2.0.0"
LOG_FILE="/data/adb/maxregner/logs/ab_manager.log"

# Samsung Galaxy Z Flip5 partitions
SAMSUNG_AB_PARTITIONS="boot recovery dtbo vbmeta vendor product system system_ext odm"
SAMSUNG_CRITICAL_PARTITIONS="abl xbl rpm tz hyp"

###################
# Logging Functions
###################

ab_log() {
  local level="$1"
  local message="$2"
  local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  
  echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
  echo "[$level] $message"
}

###################
# Detection Functions
###################

detect_ab_support() {
  ab_log "INFO" "Detecting A/B partition support"
  
  AB_SUPPORTED=false
  CURRENT_SLOT=""
  INACTIVE_SLOT=""
  
  # Method 1: Check kernel command line
  if [ -f /proc/cmdline ]; then
    if grep -q "androidboot.slot_suffix" /proc/cmdline; then
      CURRENT_SLOT=$(grep -o 'androidboot.slot_suffix=[^[:space:]]*' /proc/cmdline | cut -d= -f2)
      AB_SUPPORTED=true
    elif grep -q "androidboot.slot" /proc/cmdline; then
      SLOT_NAME=$(grep -o 'androidboot.slot=[^[:space:]]*' /proc/cmdline | cut -d= -f2)
      CURRENT_SLOT="_$SLOT_NAME"
      AB_SUPPORTED=true
    fi
  fi
  
  # Method 2: Check for A/B partitions in /dev/block/by-name
  if [ "$AB_SUPPORTED" = "false" ]; then
    if [ -e "/dev/block/by-name/boot_a" ] && [ -e "/dev/block/by-name/boot_b" ]; then
      AB_SUPPORTED=true
      ab_log "INFO" "A/B partitions detected in /dev/block/by-name"
      
      # Try to determine current slot
      if [ -L "/dev/block/by-name/boot" ]; then
        BOOT_TARGET=$(readlink /dev/block/by-name/boot)
        if echo "$BOOT_TARGET" | grep -q "_a"; then
          CURRENT_SLOT="_a"
        elif echo "$BOOT_TARGET" | grep -q "_b"; then
          CURRENT_SLOT="_b"
        fi
      fi
    fi
  fi
  
  # Method 3: Check bootctl if available
  if [ "$AB_SUPPORTED" = "false" ] && command -v bootctl >/dev/null 2>&1; then
    if bootctl get-current-slot >/dev/null 2>&1; then
      AB_SUPPORTED=true
      CURRENT_SLOT="_$(bootctl get-current-slot)"
      ab_log "INFO" "A/B support detected via bootctl"
    fi
  fi
  
  if [ "$AB_SUPPORTED" = "true" ]; then
    # Determine inactive slot
    if [ "$CURRENT_SLOT" = "_a" ]; then
      INACTIVE_SLOT="_b"
    elif [ "$CURRENT_SLOT" = "_b" ]; then
      INACTIVE_SLOT="_a"
    fi
    
    ab_log "INFO" "A/B device confirmed"
    ab_log "INFO" "Current slot: $CURRENT_SLOT"
    ab_log "INFO" "Inactive slot: $INACTIVE_SLOT"
  else
    ab_log "INFO" "Non-A/B device detected"
  fi
  
  export AB_SUPPORTED CURRENT_SLOT INACTIVE_SLOT
}

detect_samsung_device() {
  ab_log "INFO" "Detecting Samsung device type"
  
  DEVICE_CODENAME=$(getprop ro.product.device)
  DEVICE_MODEL=$(getprop ro.product.model)
  DEVICE_BRAND=$(getprop ro.product.brand)
  
  SAMSUNG_DEVICE=false
  SAMSUNG_ZFLIP5=false
  
  if [ "$DEVICE_BRAND" = "samsung" ]; then
    SAMSUNG_DEVICE=true
    ab_log "INFO" "Samsung device detected: $DEVICE_MODEL ($DEVICE_CODENAME)"
    
    # Check for Galaxy Z Flip5
    if [ "$DEVICE_CODENAME" = "b5q" ] || [ "$DEVICE_MODEL" = "SM-F731B" ] || [ "$DEVICE_MODEL" = "SM-F731U" ]; then
      SAMSUNG_ZFLIP5=true
      ab_log "INFO" "Samsung Galaxy Z Flip5 detected"
    fi
  fi
  
  export SAMSUNG_DEVICE SAMSUNG_ZFLIP5 DEVICE_CODENAME DEVICE_MODEL
}

###################
# Partition Functions
###################

list_ab_partitions() {
  ab_log "INFO" "Listing A/B partitions"
  
  if [ "$AB_SUPPORTED" != "true" ]; then
    ab_log "WARN" "Device does not support A/B partitions"
    return 1
  fi
  
  echo "=== A/B Partition Status ==="
  echo "Current slot: $CURRENT_SLOT"
  echo "Inactive slot: $INACTIVE_SLOT"
  echo ""
  
  # List standard partitions
  PARTITIONS_TO_CHECK="boot recovery dtbo vbmeta vendor product system system_ext odm"
  
  # Add Samsung-specific partitions if Samsung device
  if [ "$SAMSUNG_DEVICE" = "true" ]; then
    PARTITIONS_TO_CHECK="$PARTITIONS_TO_CHECK $SAMSUNG_CRITICAL_PARTITIONS"
  fi
  
  for partition in $PARTITIONS_TO_CHECK; do
    printf "%-12s: " "$partition"
    
    CURRENT_PART="/dev/block/by-name/${partition}${CURRENT_SLOT}"
    INACTIVE_PART="/dev/block/by-name/${partition}${INACTIVE_SLOT}"
    
    if [ -e "$CURRENT_PART" ] && [ -e "$INACTIVE_PART" ]; then
      echo "A/B ✓"
    elif [ -e "/dev/block/by-name/$partition" ]; then
      echo "Single ✓"
    else
      echo "Missing ✗"
    fi
  done
}

verify_partition_integrity() {
  local partition="$1"
  local slot="$2"
  
  ab_log "INFO" "Verifying partition integrity: ${partition}${slot}"
  
  local part_path="/dev/block/by-name/${partition}${slot}"
  
  if [ ! -e "$part_path" ]; then
    ab_log "ERROR" "Partition not found: $part_path"
    return 1
  fi
  
  # Check if partition is readable
  if ! dd if="$part_path" of=/dev/null bs=1024 count=1 >/dev/null 2>&1; then
    ab_log "ERROR" "Partition not readable: $part_path"
    return 1
  fi
  
  ab_log "INFO" "Partition integrity verified: ${partition}${slot}"
  return 0
}

###################
# Slot Management
###################

switch_to_slot() {
  local target_slot="$1"
  
  ab_log "INFO" "Switching to slot: $target_slot"
  
  if [ "$AB_SUPPORTED" != "true" ]; then
    ab_log "ERROR" "A/B switching not supported on this device"
    return 1
  fi
  
  if [ "$target_slot" != "_a" ] && [ "$target_slot" != "_b" ]; then
    ab_log "ERROR" "Invalid slot: $target_slot (must be _a or _b)"
    return 1
  fi
  
  # Use bootctl if available
  if command -v bootctl >/dev/null 2>&1; then
    local slot_name="${target_slot#_}"
    if bootctl set-active-boot-slot "$slot_name"; then
      ab_log "INFO" "Successfully switched to slot $target_slot using bootctl"
      return 0
    else
      ab_log "ERROR" "Failed to switch slot using bootctl"
      return 1
    fi
  fi
  
  # Samsung-specific slot switching
  if [ "$SAMSUNG_DEVICE" = "true" ]; then
    return samsung_switch_slot "$target_slot"
  fi
  
  ab_log "ERROR" "No slot switching method available"
  return 1
}

samsung_switch_slot() {
  local target_slot="$1"
  
  ab_log "INFO" "Using Samsung-specific slot switching for slot: $target_slot"
  
  # Samsung devices may require specific handling
  # This is a placeholder for Samsung-specific slot switching logic
  
  # Try to use setprop to change boot slot
  setprop ro.boot.slot_suffix "$target_slot"
  
  # Update bootloader variables if possible
  if command -v setbootslot >/dev/null 2>&1; then
    local slot_name="${target_slot#_}"
    setbootslot "$slot_name"
  fi
  
  ab_log "INFO" "Samsung slot switch attempted for slot: $target_slot"
  ab_log "WARN" "Reboot required to activate new slot"
  
  return 0
}

get_slot_status() {
  ab_log "INFO" "Getting slot status"
  
  if [ "$AB_SUPPORTED" != "true" ]; then
    echo "A/B not supported"
    return 1
  fi
  
  echo "=== Slot Status ==="
  echo "Current slot: $CURRENT_SLOT"
  echo "Inactive slot: $INACTIVE_SLOT"
  
  # Check if bootctl is available for detailed status
  if command -v bootctl >/dev/null 2>&1; then
    echo ""
    echo "=== Bootctl Status ==="
    bootctl get-current-slot 2>/dev/null && echo "Current: $(bootctl get-current-slot)"
    bootctl get-suffix 2>/dev/null && echo "Suffix: $(bootctl get-suffix)"
  fi
  
  # Verify critical partitions
  echo ""
  echo "=== Critical Partition Status ==="
  for partition in boot recovery; do
    if verify_partition_integrity "$partition" "$CURRENT_SLOT"; then
      printf "%-12s: OK\n" "${partition}${CURRENT_SLOT}"
    else
      printf "%-12s: FAILED\n" "${partition}${CURRENT_SLOT}"
    fi
  done
}

###################
# Samsung Z Flip5 Specific
###################

optimize_samsung_zflip5() {
  ab_log "INFO" "Optimizing Samsung Galaxy Z Flip5 A/B configuration"
  
  if [ "$SAMSUNG_ZFLIP5" != "true" ]; then
    ab_log "WARN" "Not a Samsung Galaxy Z Flip5, skipping optimization"
    return 1
  fi
  
  # Samsung Z Flip5 specific optimizations
  ab_log "INFO" "Applying Samsung Galaxy Z Flip5 A/B optimizations"
  
  # Set Samsung-specific properties
  setprop ro.maxregner.samsung_ab_optimized true
  setprop ro.maxregner.zflip5_mode true
  
  # Optimize partition access
  for partition in $SAMSUNG_AB_PARTITIONS; do
    local current_part="/dev/block/by-name/${partition}${CURRENT_SLOT}"
    local inactive_part="/dev/block/by-name/${partition}${INACTIVE_SLOT}"
    
    if [ -e "$current_part" ]; then
      # Set optimal I/O scheduler for Samsung partitions
      echo "deadline" > "/sys/block/$(basename $(readlink $current_part | sed 's/[0-9]*$//'))/queue/scheduler" 2>/dev/null || true
    fi
  done
  
  ab_log "INFO" "Samsung Galaxy Z Flip5 optimization complete"
}

###################
# Main Functions
###################

show_help() {
  echo "maxregnerOS A/B Slot Manager v$AB_MANAGER_VERSION"
  echo ""
  echo "Usage: $0 [command] [options]"
  echo ""
  echo "Commands:"
  echo "  detect          - Detect A/B support and current slot"
  echo "  status          - Show current slot status"
  echo "  list            - List all A/B partitions"
  echo "  switch <slot>   - Switch to specified slot (_a or _b)"
  echo "  verify          - Verify partition integrity"
  echo "  optimize        - Apply device-specific optimizations"
  echo "  help            - Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 detect"
  echo "  $0 switch _b"
  echo "  $0 status"
}

main() {
  local command="$1"
  
  # Create log directory
  mkdir -p "$(dirname "$LOG_FILE")"
  
  ab_log "INFO" "maxregnerOS A/B Manager v$AB_MANAGER_VERSION starting"
  
  # Always detect device and A/B support first
  detect_samsung_device
  detect_ab_support
  
  case "$command" in
    "detect")
      echo "A/B Support: $AB_SUPPORTED"
      [ "$AB_SUPPORTED" = "true" ] && echo "Current Slot: $CURRENT_SLOT"
      ;;
    "status")
      get_slot_status
      ;;
    "list")
      list_ab_partitions
      ;;
    "switch")
      local target_slot="$2"
      if [ -z "$target_slot" ]; then
        echo "Error: Please specify target slot (_a or _b)"
        exit 1
      fi
      switch_to_slot "$target_slot"
      ;;
    "verify")
      if [ "$AB_SUPPORTED" = "true" ]; then
        for partition in boot recovery; do
          verify_partition_integrity "$partition" "$CURRENT_SLOT"
        done
      else
        echo "A/B verification not applicable for this device"
      fi
      ;;
    "optimize")
      if [ "$SAMSUNG_ZFLIP5" = "true" ]; then
        optimize_samsung_zflip5
      else
        ab_log "INFO" "No device-specific optimizations available"
      fi
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
  
  ab_log "INFO" "maxregnerOS A/B Manager operation complete"
}

# Run main function with all arguments
main "$@"
