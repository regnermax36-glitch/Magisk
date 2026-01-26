############################################
# maxregnerOS Utility Functions
# Custom functions for OS restructuring
############################################

###################
# Filesystem Functions
###################

install_maxregneros_filesystem() {
  ui_print "- Creating maxregnerOS filesystem structure"
  
  # Create maxregnerOS directories
  mkdir -p /data/maxregneros/system
  mkdir -p /data/maxregneros/vendor
  mkdir -p /data/maxregneros/product
  mkdir -p /data/maxregneros/odm
  mkdir -p /data/maxregneros/apex
  mkdir -p /data/maxregneros/config
  mkdir -p /data/maxregneros/themes
  mkdir -p /data/maxregneros/modules
  
  # Set proper permissions
  chmod 755 /data/maxregneros
  chmod 755 /data/maxregneros/*
  
  # Create filesystem overlay structure
  create_overlay_structure
  
  # Install custom init scripts
  install_maxregneros_init
}

create_overlay_structure() {
  ui_print "- Setting up overlay filesystem"
  
  # Create overlay mount points
  mkdir -p /data/maxregneros/overlay/system
  mkdir -p /data/maxregneros/overlay/vendor
  mkdir -p /data/maxregneros/overlay/product
  
  # Create work directories for overlayfs
  mkdir -p /data/maxregneros/work/system
  mkdir -p /data/maxregneros/work/vendor
  mkdir -p /data/maxregneros/work/product
  
  # Set SELinux contexts
  chcon -R u:object_r:system_file:s0 /data/maxregneros/overlay/system 2>/dev/null
  chcon -R u:object_r:vendor_file:s0 /data/maxregneros/overlay/vendor 2>/dev/null
  chcon -R u:object_r:system_file:s0 /data/maxregneros/overlay/product 2>/dev/null
}

install_maxregneros_init() {
  ui_print "- Installing maxregnerOS init scripts"
  
  # Create init.d directory
  mkdir -p /data/maxregneros/init.d
  
  # Install filesystem mount script
  cat > /data/maxregneros/init.d/01-filesystem.sh << 'EOF'
#!/system/bin/sh
# maxregnerOS Filesystem Mount Script

# Mount overlayfs for system modifications
mount -t overlay overlay -o lowerdir=/system,upperdir=/data/maxregneros/overlay/system,workdir=/data/maxregneros/work/system /system 2>/dev/null

# Mount overlayfs for vendor modifications  
mount -t overlay overlay -o lowerdir=/vendor,upperdir=/data/maxregneros/overlay/vendor,workdir=/data/maxregneros/work/vendor /vendor 2>/dev/null

# Mount overlayfs for product modifications
mount -t overlay overlay -o lowerdir=/product,upperdir=/data/maxregneros/overlay/product,workdir=/data/maxregneros/work/product /product 2>/dev/null

# Set proper permissions
chmod 755 /data/maxregneros/overlay/*
EOF
  
  chmod 755 /data/maxregneros/init.d/01-filesystem.sh
}

###################
# UI Functions
###################

install_maxregneros_ui() {
  ui_print "- Installing maxregnerOS UI components"
  
  # Install custom SystemUI
  install_custom_systemui
  
  # Install custom launcher
  install_custom_launcher
  
  # Install custom framework
  install_custom_framework
  
  # Install themes and icons
  install_themes_and_icons
}

install_custom_systemui() {
  ui_print "- Installing maxregnerOS SystemUI"
  
  # Create SystemUI overlay directory
  mkdir -p /data/maxregneros/overlay/system/system_ext/priv-app/SystemUI
  
  # Copy custom SystemUI APK (placeholder - you'll need to provide actual APK)
  if [ -f $MAXREGNEROS_DIR/ui/SystemUI.apk ]; then
    cp $MAXREGNEROS_DIR/ui/SystemUI.apk /data/maxregneros/overlay/system/system_ext/priv-app/SystemUI/SystemUI.apk
    chmod 644 /data/maxregneros/overlay/system/system_ext/priv-app/SystemUI/SystemUI.apk
  fi
  
  # Install SystemUI configuration
  mkdir -p /data/maxregneros/overlay/system/etc/sysconfig
  cat > /data/maxregneros/overlay/system/etc/sysconfig/maxregneros-systemui.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<config>
    <privapp-permissions package="com.android.systemui">
        <permission name="android.permission.CONTROL_KEYGUARD"/>
        <permission name="android.permission.MODIFY_PHONE_STATE"/>
        <permission name="android.permission.WRITE_MEDIA_STORAGE"/>
        <permission name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    </privapp-permissions>
</config>
EOF
}

install_custom_launcher() {
  ui_print "- Installing maxregnerOS Launcher"
  
  # Create launcher directory
  mkdir -p /data/maxregneros/overlay/system/priv-app/MaxregnerLauncher
  
  # Copy custom launcher APK (placeholder)
  if [ -f $MAXREGNEROS_DIR/ui/MaxregnerLauncher.apk ]; then
    cp $MAXREGNEROS_DIR/ui/MaxregnerLauncher.apk /data/maxregneros/overlay/system/priv-app/MaxregnerLauncher/MaxregnerLauncher.apk
    chmod 644 /data/maxregneros/overlay/system/priv-app/MaxregnerLauncher/MaxregnerLauncher.apk
  fi
}

install_custom_framework() {
  ui_print "- Installing maxregnerOS Framework modifications"
  
  # Create framework overlay
  mkdir -p /data/maxregneros/overlay/system/framework
  
  # Install custom framework-res.apk modifications
  if [ -f $MAXREGNEROS_DIR/framework/framework-res.apk ]; then
    cp $MAXREGNEROS_DIR/framework/framework-res.apk /data/maxregneros/overlay/system/framework/framework-res.apk
    chmod 644 /data/maxregneros/overlay/system/framework/framework-res.apk
  fi
}

install_themes_and_icons() {
  ui_print "- Installing maxregnerOS themes and icons"
  
  # Create themes directory
  mkdir -p /data/maxregneros/themes/maxregner
  mkdir -p /data/maxregneros/overlay/system/media/theme
  
  # Install icon packs
  if [ -d $MAXREGNEROS_DIR/themes/icons ]; then
    cp -r $MAXREGNEROS_DIR/themes/icons/* /data/maxregneros/overlay/system/media/theme/
  fi
  
  # Install boot animation
  if [ -f $MAXREGNEROS_DIR/themes/bootanimation.zip ]; then
    cp $MAXREGNEROS_DIR/themes/bootanimation.zip /data/maxregneros/overlay/system/media/bootanimation.zip
    chmod 644 /data/maxregneros/overlay/system/media/bootanimation.zip
  fi
}

###################
# System Tweaks
###################

apply_maxregneros_tweaks() {
  ui_print "- Applying maxregnerOS system tweaks"
  
  # Apply build.prop modifications
  apply_build_prop_tweaks
  
  # Apply performance tweaks
  apply_performance_tweaks
  
  # Apply Samsung-specific tweaks for Z Flip5
  apply_samsung_tweaks
  
  # Apply security tweaks
  apply_security_tweaks
}

apply_build_prop_tweaks() {
  ui_print "- Applying build.prop modifications"
  
  # Create build.prop overlay
  mkdir -p /data/maxregneros/overlay/system/etc
  
  # Add maxregnerOS identification
  cat >> /data/maxregneros/overlay/system/etc/build.prop << 'EOF'

# maxregnerOS Properties
ro.maxregneros.version=1.0.0
ro.maxregneros.codename=Regner
ro.maxregneros.device=zflip5
ro.maxregneros.build.date=$(date +%Y%m%d)
ro.maxregneros.build.type=user

# Performance tweaks
ro.config.max_starting_bg=8
ro.sys.fw.bg_apps_limit=24
ro.config.dha_cached_max=16
ro.config.dha_empty_max=24

# UI tweaks
ro.surface_flinger.max_frame_buffer_acquired_buffers=3
ro.surface_flinger.running_without_sync_framework=true
ro.surface_flinger.vsync_event_phase_offset_ns=2000000
ro.surface_flinger.vsync_sf_event_phase_offset_ns=6000000

# Samsung specific
ro.config.tima=0
ro.config.knox=0
ro.security.mdpp.ux=Disabled
EOF
}

apply_performance_tweaks() {
  ui_print "- Applying performance optimizations"
  
  # Create performance script
  cat > /data/maxregneros/init.d/02-performance.sh << 'EOF'
#!/system/bin/sh
# maxregnerOS Performance Tweaks

# CPU Governor tweaks
echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null
echo "performance" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor 2>/dev/null
echo "performance" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor 2>/dev/null

# GPU tweaks
echo "performance" > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null

# I/O scheduler tweaks
echo "deadline" > /sys/block/sda/queue/scheduler 2>/dev/null
echo "deadline" > /sys/block/sdb/queue/scheduler 2>/dev/null

# Memory tweaks
echo "1" > /proc/sys/vm/drop_caches
echo "60" > /proc/sys/vm/swappiness
echo "100" > /proc/sys/vm/vfs_cache_pressure
EOF
  
  chmod 755 /data/maxregneros/init.d/02-performance.sh
}

apply_samsung_tweaks() {
  ui_print "- Applying Samsung Galaxy Z Flip5 specific tweaks"
  
  # Create Samsung-specific script
  cat > /data/maxregneros/init.d/03-samsung.sh << 'EOF'
#!/system/bin/sh
# Samsung Galaxy Z Flip5 Specific Tweaks

# Disable Samsung bloatware services
pm disable com.samsung.android.bixby.agent 2>/dev/null
pm disable com.samsung.android.visionintelligence 2>/dev/null
pm disable com.samsung.android.samsungpass 2>/dev/null
pm disable com.samsung.android.spay 2>/dev/null

# Optimize for foldable display
setprop ro.surface_flinger.use_content_detection_for_refresh_rate true
setprop ro.surface_flinger.set_display_power_timer_ms 1000
setprop ro.surface_flinger.set_idle_timer_ms 200

# Battery optimization for dual displays
echo "1" > /sys/class/power_supply/battery/store_mode 2>/dev/null
EOF
  
  chmod 755 /data/maxregneros/init.d/03-samsung.sh
}

apply_security_tweaks() {
  ui_print "- Applying security enhancements"
  
  # Create security script
  cat > /data/maxregneros/init.d/04-security.sh << 'EOF'
#!/system/bin/sh
# maxregnerOS Security Tweaks

# Disable unnecessary services
stop tima_measurement_agent 2>/dev/null
stop knox_chk_app 2>/dev/null
stop tz_ccm 2>/dev/null

# Enable additional security features
setprop ro.adb.secure 1
setprop ro.secure 1
setprop ro.debuggable 0
EOF
  
  chmod 755 /data/maxregneros/init.d/04-security.sh
}

###################
# Utility Functions
###################

backup_original_system() {
  ui_print "- Creating system backup"
  
  mkdir -p /data/maxregneros/backup
  
  # Backup critical system files
  cp /system/build.prop /data/maxregneros/backup/build.prop.bak 2>/dev/null
  cp -r /system/etc/init /data/maxregneros/backup/init.bak 2>/dev/null
}

restore_original_system() {
  ui_print "- Restoring original system"
  
  if [ -d /data/maxregneros/backup ]; then
    cp /data/maxregneros/backup/build.prop.bak /system/build.prop 2>/dev/null
    cp -r /data/maxregneros/backup/init.bak /system/etc/init 2>/dev/null
  fi
}

check_maxregneros_status() {
  if [ -d /data/maxregneros ] && [ -f /data/maxregneros/init.d/01-filesystem.sh ]; then
    return 0
  else
    return 1
  fi
}
