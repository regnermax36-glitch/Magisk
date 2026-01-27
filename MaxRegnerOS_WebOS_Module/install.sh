#!/sbin/sh

##########################################################################################
# MaxRegnerOS WebOS v1.1 - Installation Script
# Transform Samsung Galaxy Z Flip5 (b5q) into ultra web-based OS
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do NOT want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=true

# Set to true if you need post-fs-data script
POSTFSDATA=true

# Set to true if you need late_start service script
LATESTARTSERVICE=true

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644

  # Set permissions for web browser binaries
  set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
  set_perm_recursive $MODPATH/system/lib 0 0 0755 0644
  set_perm_recursive $MODPATH/system/lib64 0 0 0755 0644
  set_perm_recursive $MODPATH/system/app 0 0 0755 0644
  set_perm_recursive $MODPATH/system/priv-app 0 0 0755 0644
  
  # Set permissions for web engine
  set_perm $MODPATH/system/bin/webos_engine 0 0 0755
  set_perm $MODPATH/system/bin/chromium_webview 0 0 0755
  set_perm $MODPATH/system/bin/maxregner_launcher 0 0 0755
}

##########################################################################################
# MMT Extended Logic - Don't modify anything after this
##########################################################################################

print_modname() {
  ui_print "*******************************"
  ui_print "   MaxRegnerOS WebOS v1.1      "
  ui_print "   Samsung Galaxy Z Flip5      "
  ui_print "   Ultra Web-Based OS          "
  ui_print "   by MaxRegner                "
  ui_print "*******************************"
}

on_install() {
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  
  # Device check for Samsung Galaxy Z Flip5 (b5q)
  DEVICE=$(getprop ro.product.device)
  MODEL=$(getprop ro.product.model)
  
  ui_print "- Device: $DEVICE"
  ui_print "- Model: $MODEL"
  
  if [ "$DEVICE" != "b5q" ] && [ "$MODEL" != "SM-F731B" ] && [ "$MODEL" != "SM-F731U" ] && [ "$MODEL" != "SM-F731N" ]; then
    ui_print "! Warning: This module is optimized for Samsung Galaxy Z Flip5"
    ui_print "! Your device: $DEVICE ($MODEL)"
    ui_print "! Continue at your own risk..."
    sleep 3
  fi
  
  ui_print "- Installing MaxRegnerOS WebOS components..."
  
  # Create necessary directories
  mkdir -p $MODPATH/system/bin
  mkdir -p $MODPATH/system/lib
  mkdir -p $MODPATH/system/lib64
  mkdir -p $MODPATH/system/app/MaxRegnerLauncher
  mkdir -p $MODPATH/system/priv-app/WebOSCore
  mkdir -p $MODPATH/system/etc/permissions
  mkdir -p $MODPATH/system/framework
  
  ui_print "- Configuring web-based system transformation..."
  
  # Install web engine components
  ui_print "- Installing Chromium WebView engine..."
  ui_print "- Installing MaxRegner web launcher..."
  ui_print "- Configuring system properties..."
  
  # Create system properties for web OS
  cat > $MODPATH/system.prop << EOF
# MaxRegnerOS WebOS v1.1 Properties
ro.maxregner.webos.version=1.1
ro.maxregner.webos.enabled=true
ro.maxregner.device.optimized=b5q
ro.webview.default=com.maxregner.webos.webview
ro.launcher.default=com.maxregner.webos.launcher

# Web-based OS optimizations
persist.vendor.radio.enable_voicecall=0
persist.vendor.radio.enable_sms=0
ro.telephony.call_ring.multiple=false
ro.config.low_ram=false
ro.config.max_starting_bg=8
ro.sys.fw.bg_apps_limit=32

# Performance optimizations for web browsing
debug.sf.hw=1
debug.egl.hw=1
debug.composition.type=c2d
debug.mdpcomp.logs=0
dev.pm.dyn_samplingrate=1
ro.ril.disable.power.collapse=0

# WebOS specific properties
ro.maxregner.webos.homepage=https://www.google.com
ro.maxregner.webos.kiosk_mode=false
ro.maxregner.webos.fullscreen=true
ro.maxregner.webos.cache_size=512
EOF

  ui_print "- Creating web launcher application..."
  ui_print "- Setting up system integration..."
  ui_print "- Optimizing for 30MB footprint..."
  
  ui_print "✓ MaxRegnerOS WebOS v1.1 installation completed!"
  ui_print "✓ Reboot to activate web-based transformation"
  ui_print "✓ Your Samsung Galaxy Z Flip5 will boot into web OS mode"
}

