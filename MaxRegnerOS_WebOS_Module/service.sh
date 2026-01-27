#!/system/bin/sh

##########################################################################################
# MaxRegnerOS WebOS v1.1 - Service Script
# This script will be executed in late_start service mode
##########################################################################################

MODDIR=${0%/*}

# Wait for system to be ready
sleep 30

# Start web OS services
echo "$(date): Starting MaxRegnerOS WebOS v1.1 services" >> /data/maxregner_webos/service.log

# Set web OS properties
setprop ro.maxregner.webos.status "running"
setprop ro.maxregner.webos.startup_time "$(date +%s)"

# Configure web browser as default launcher
if [ -f /system/bin/maxregner_launcher ]; then
    # Set as default home app
    pm enable com.maxregner.webos.launcher/.MainActivity 2>/dev/null
    pm set-home-activity com.maxregner.webos.launcher/.MainActivity 2>/dev/null
fi

# Optimize system for web browsing
# Disable unnecessary services to save resources
pm disable com.samsung.android.bixby.agent 2>/dev/null
pm disable com.samsung.android.app.spage 2>/dev/null
pm disable com.samsung.android.game.gametools 2>/dev/null
pm disable com.samsung.android.gametuner.thin 2>/dev/null

# Enable web-optimized settings
settings put global animator_duration_scale 0.5
settings put global transition_animation_scale 0.5
settings put global window_animation_scale 0.5

# Configure network optimizations
echo 'net.core.rmem_default = 262144' >> /proc/sys/net/core/rmem_default 2>/dev/null
echo 'net.core.rmem_max = 16777216' >> /proc/sys/net/core/rmem_max 2>/dev/null
echo 'net.core.wmem_default = 262144' >> /proc/sys/net/core/wmem_default 2>/dev/null
echo 'net.core.wmem_max = 16777216' >> /proc/sys/net/core/wmem_max 2>/dev/null

# Set up web cache optimization
if [ -d /data/maxregner_webos/cache ]; then
    # Limit cache size to 512MB
    find /data/maxregner_webos/cache -type f -size +512M -delete 2>/dev/null
fi

# Start web OS monitoring
(
    while true; do
        # Monitor memory usage
        MEMINFO=$(cat /proc/meminfo | grep MemAvailable | awk '{print $2}')
        if [ "$MEMINFO" -lt 1048576 ]; then  # Less than 1GB available
            # Clear web cache if memory is low
            rm -rf /data/maxregner_webos/cache/* 2>/dev/null
            echo "$(date): Memory cleanup performed - Available: ${MEMINFO}KB" >> /data/maxregner_webos/service.log
        fi
        sleep 300  # Check every 5 minutes
    done
) &

echo "$(date): MaxRegnerOS WebOS v1.1 services started successfully" >> /data/maxregner_webos/service.log

