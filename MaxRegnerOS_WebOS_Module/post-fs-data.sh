#!/system/bin/sh

##########################################################################################
# MaxRegnerOS WebOS v1.1 - Post-FS-Data Script
# This script will be executed in post-fs-data mode
##########################################################################################

# Set up web OS environment
MODDIR=${0%/*}

# Create web OS directories
mkdir -p /data/maxregner_webos
mkdir -p /data/maxregner_webos/cache
mkdir -p /data/maxregner_webos/data
mkdir -p /data/maxregner_webos/profiles

# Set permissions
chmod 755 /data/maxregner_webos
chmod 755 /data/maxregner_webos/cache
chmod 755 /data/maxregner_webos/data
chmod 755 /data/maxregner_webos/profiles

# Create web OS configuration
cat > /data/maxregner_webos/config.json << EOF
{
  "version": "1.1",
  "device": "b5q",
  "webos_mode": true,
  "kiosk_mode": false,
  "homepage": "https://www.google.com",
  "cache_size_mb": 512,
  "fullscreen": true,
  "user_agent": "MaxRegnerOS/1.1 (Samsung Galaxy Z Flip5; Android)",
  "features": {
    "web_apps": true,
    "offline_mode": true,
    "cloud_sync": false,
    "developer_tools": true
  }
}
EOF

# Set up web engine
if [ -f /system/bin/webos_engine ]; then
    chmod 755 /system/bin/webos_engine
fi

if [ -f /system/bin/chromium_webview ]; then
    chmod 755 /system/bin/chromium_webview
fi

if [ -f /system/bin/maxregner_launcher ]; then
    chmod 755 /system/bin/maxregner_launcher
fi

# Log installation
echo "$(date): MaxRegnerOS WebOS v1.1 post-fs-data executed" >> /data/maxregner_webos/install.log

