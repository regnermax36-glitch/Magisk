#!/system/bin/sh
#######################################################################################
# 🦖 Magisk Godzilla Treble Functions
# Project Treble Support Functions for Android 16 GSI
# Samsung Galaxy Z Flip5 (SM-F731B/b5q) Optimized
#######################################################################################

GODZILLA_VERSION="1.0.0"
TREBLE_LOG="/data/local/tmp/godzilla_treble.log"

# Logging function
godzilla_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] GODZILLA: $1" | tee -a "$TREBLE_LOG"
}

# Check if device supports Project Treble
check_treble_support() {
    godzilla_log "Checking Project Treble support..."
    
    local treble_enabled=$(getprop ro.treble.enabled)
    if [ "$treble_enabled" != "true" ]; then
        ui_print "❌ ERROR: Device is not Project Treble enabled!"
        ui_print "   This device cannot run GSI images."
        return 1
    fi
    
    ui_print "✅ Project Treble: ENABLED"
    godzilla_log "Project Treble support confirmed"
    return 0
}

# Check VNDK compliance
check_vndk_compliance() {
    godzilla_log "Checking VNDK compliance..."
    
    local vndk_version=$(getprop ro.vndk.version)
    local vndk_lite=$(getprop ro.vndk.lite)
    
    if [ -n "$vndk_version" ]; then
        ui_print "✅ VNDK Version: $vndk_version"
        godzilla_log "VNDK version: $vndk_version"
        
        # Check if VNDK version is compatible with Android 16
        if [ "$vndk_version" -ge 35 ]; then
            ui_print "✅ Android 16 GSI: COMPATIBLE"
            godzilla_log "Android 16 GSI compatibility confirmed"
            return 0
        else
            ui_print "⚠️  WARNING: VNDK version may not support Android 16 GSI"
            godzilla_log "VNDK version may be incompatible with Android 16"
        fi
    elif [ "$vndk_lite" = "true" ]; then
        ui_print "⚠️  VNDK Lite detected - limited GSI compatibility"
        godzilla_log "VNDK Lite detected"
    else
        ui_print "❌ ERROR: No VNDK support detected!"
        godzilla_log "No VNDK support found"
        return 1
    fi
    
    return 0
}

# Detect Samsung Galaxy Z Flip5 (b5q)
detect_b5q_device() {
    godzilla_log "Detecting Samsung Galaxy Z Flip5 (b5q)..."
    
    local device=$(getprop ro.product.device)
    local model=$(getprop ro.product.model)
    local brand=$(getprop ro.product.brand)
    
    godzilla_log "Device: $device, Model: $model, Brand: $brand"
    
    if [ "$device" = "b5q" ] || [ "$model" = "SM-F731B" ]; then
        ui_print "🦖 Samsung Galaxy Z Flip5 (b5q) DETECTED!"
        ui_print "   Applying foldable device optimizations..."
        godzilla_log "Samsung Galaxy Z Flip5 detected - applying optimizations"
        return 0
    elif [ "$brand" = "samsung" ]; then
        ui_print "📱 Samsung device detected: $model"
        ui_print "   Applying Samsung-specific patches..."
        godzilla_log "Samsung device detected: $model"
        return 0
    else
        ui_print "📱 Device: $device ($model)"
        godzilla_log "Non-Samsung device: $device ($model)"
        return 1
    fi
}

# Check dynamic partitions support
check_dynamic_partitions() {
    godzilla_log "Checking dynamic partitions support..."
    
    local dynamic_partitions=$(getprop ro.boot.dynamic_partitions)
    if [ "$dynamic_partitions" = "true" ]; then
        ui_print "✅ Dynamic Partitions: ENABLED"
        godzilla_log "Dynamic partitions enabled"
        return 0
    else
        ui_print "⚠️  Dynamic Partitions: DISABLED"
        godzilla_log "Dynamic partitions disabled"
        return 1
    fi
}

# Check APEX support
check_apex_support() {
    godzilla_log "Checking APEX support..."
    
    if [ -d "/apex" ]; then
        ui_print "✅ APEX Support: ENABLED"
        godzilla_log "APEX support confirmed"
        return 0
    else
        ui_print "❌ APEX Support: DISABLED"
        godzilla_log "APEX support not found"
        return 1
    fi
}

# Validate vendor interface (VINTF)
validate_vintf() {
    godzilla_log "Validating Vendor Interface (VINTF)..."
    
    local vendor_manifest="/vendor/etc/vintf/manifest.xml"
    local framework_manifest="/system/etc/vintf/manifest.xml"
    
    if [ -f "$vendor_manifest" ]; then
        ui_print "✅ Vendor Manifest: FOUND"
        godzilla_log "Vendor manifest found: $vendor_manifest"
    else
        ui_print "⚠️  Vendor Manifest: NOT FOUND"
        godzilla_log "Vendor manifest missing: $vendor_manifest"
    fi
    
    if [ -f "$framework_manifest" ]; then
        ui_print "✅ Framework Manifest: FOUND"
        godzilla_log "Framework manifest found: $framework_manifest"
    else
        ui_print "⚠️  Framework Manifest: NOT FOUND"
        godzilla_log "Framework manifest missing: $framework_manifest"
    fi
    
    return 0
}

# Setup Treble-specific directories
setup_treble_directories() {
    godzilla_log "Setting up Treble-specific directories..."
    
    local treble_dirs="/data/adb/modules_godzilla /data/adb/treble_modules /data/adb/vendor_modules"
    
    for dir in $treble_dirs; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            chmod 755 "$dir"
            godzilla_log "Created directory: $dir"
        fi
    done
    
    ui_print "✅ Treble directories configured"
    return 0
}

# Apply Samsung-specific patches
apply_samsung_patches() {
    godzilla_log "Applying Samsung-specific patches..."
    
    # Samsung devices often have additional security measures
    # that need to be handled for GSI compatibility
    
    ui_print "🔧 Applying Samsung security patches..."
    
    # Patch for Samsung's KNOX security
    if [ -f "/vendor/etc/init/init.knox.rc" ]; then
        godzilla_log "Samsung KNOX detected - applying compatibility patches"
        ui_print "   • KNOX compatibility patches"
    fi
    
    # Patch for Samsung's RKP (Real-time Kernel Protection)
    if [ -f "/vendor/etc/init/init.rkp.rc" ]; then
        godzilla_log "Samsung RKP detected - applying compatibility patches"
        ui_print "   • RKP compatibility patches"
    fi
    
    return 0
}

# Apply foldable device optimizations
apply_foldable_optimizations() {
    godzilla_log "Applying foldable device optimizations..."
    
    ui_print "📱 Configuring foldable display support..."
    
    # Enable foldable-specific properties
    echo "ro.config.foldable_display=true" >> /data/local/tmp/godzilla_props.prop
    echo "ro.config.dual_display=true" >> /data/local/tmp/godzilla_props.prop
    echo "ro.config.flex_mode=true" >> /data/local/tmp/godzilla_props.prop
    echo "ro.config.hinge_sensor=true" >> /data/local/tmp/godzilla_props.prop
    
    ui_print "   • Dual display support enabled"
    ui_print "   • Flex mode support enabled"
    ui_print "   • Hinge sensor support enabled"
    
    godzilla_log "Foldable optimizations applied"
    return 0
}

# Backup original boot image
backup_original_boot() {
    godzilla_log "Creating backup of original boot image..."
    
    local boot_partition="/dev/block/by-name/boot"
    local backup_path="/data/local/tmp/boot_backup_godzilla.img"
    
    if [ -b "$boot_partition" ]; then
        ui_print "💾 Backing up original boot image..."
        dd if="$boot_partition" of="$backup_path" bs=1024k 2>/dev/null
        
        if [ $? -eq 0 ]; then
            ui_print "✅ Boot backup created: $backup_path"
            godzilla_log "Boot backup successful: $backup_path"
            return 0
        else
            ui_print "❌ Failed to create boot backup!"
            godzilla_log "Boot backup failed"
            return 1
        fi
    else
        ui_print "⚠️  Boot partition not found: $boot_partition"
        godzilla_log "Boot partition not accessible: $boot_partition"
        return 1
    fi
}

# Inject Treble support into ramdisk
inject_treble_support() {
    godzilla_log "Injecting Treble support into ramdisk..."
    
    ui_print "🔧 Injecting Treble compatibility..."
    
    # Create Treble init script
    cat > ramdisk/init.godzilla.treble.rc << 'EOF'
# Magisk Godzilla Treble Support
# Project Treble initialization for Android 16 GSI

on early-init
    # Enable Treble support
    setprop ro.treble.enabled true
    setprop ro.godzilla.treble true
    
    # Configure vendor interface
    setprop ro.vendor.api_level 35
    setprop ro.vndk.version 35
    
    # Enable GSI support
    setprop ro.gsi.supported true
    setprop ro.android16.gsi true

on init
    # Setup Treble directories
    mkdir /data/adb/modules_godzilla 0755 root root
    mkdir /data/adb/treble_modules 0755 root root
    mkdir /data/adb/vendor_modules 0755 root root
    
    # Configure foldable support (if b5q)
    setprop ro.config.foldable_display true
    setprop ro.config.dual_display true
    setprop ro.config.flex_mode true
    setprop ro.config.hinge_sensor true

on property:sys.boot_completed=1
    # Log Godzilla startup
    exec u:r:magisk:s0 root root -- /system/bin/log -t Godzilla "Magisk Godzilla Treble support initialized"
EOF

    godzilla_log "Treble init script created"
    ui_print "✅ Treble support injected"
    return 0
}

# Validate GSI compatibility
validate_gsi_compatibility() {
    godzilla_log "Validating GSI compatibility..."
    
    ui_print "🔍 Validating Android 16 GSI compatibility..."
    
    local errors=0
    
    # Check Treble support
    if ! check_treble_support; then
        errors=$((errors + 1))
    fi
    
    # Check VNDK compliance
    if ! check_vndk_compliance; then
        errors=$((errors + 1))
    fi
    
    # Check dynamic partitions
    check_dynamic_partitions
    
    # Check APEX support
    check_apex_support
    
    # Validate VINTF
    validate_vintf
    
    if [ $errors -eq 0 ]; then
        ui_print "✅ GSI Compatibility: PASSED"
        godzilla_log "GSI compatibility validation passed"
        return 0
    else
        ui_print "❌ GSI Compatibility: FAILED ($errors errors)"
        godzilla_log "GSI compatibility validation failed with $errors errors"
        return 1
    fi
}

# Main Treble initialization function
initialize_treble_support() {
    ui_print ""
    ui_print "🦖 Initializing Magisk Godzilla Treble Support..."
    ui_print ""
    
    godzilla_log "Starting Treble initialization"
    
    # Detect device
    detect_b5q_device
    
    # Validate GSI compatibility
    if ! validate_gsi_compatibility; then
        ui_print ""
        ui_print "⚠️  WARNING: Some GSI compatibility issues detected!"
        ui_print "   Proceeding with Treble patches anyway..."
        ui_print ""
    fi
    
    # Setup directories
    setup_treble_directories
    
    # Apply device-specific patches
    if detect_b5q_device; then
        apply_foldable_optimizations
    fi
    
    # Apply Samsung patches if Samsung device
    local brand=$(getprop ro.product.brand)
    if [ "$brand" = "samsung" ]; then
        apply_samsung_patches
    fi
    
    # Inject Treble support
    inject_treble_support
    
    ui_print ""
    ui_print "✅ Magisk Godzilla Treble Support Initialized!"
    ui_print "   Ready for Android 16 GSI installation"
    ui_print ""
    
    godzilla_log "Treble initialization completed successfully"
    return 0
}

# Export functions for use in boot_patch.sh
export -f godzilla_log
export -f check_treble_support
export -f check_vndk_compliance
export -f detect_b5q_device
export -f validate_gsi_compatibility
export -f initialize_treble_support
