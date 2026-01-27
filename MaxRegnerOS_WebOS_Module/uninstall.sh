#!/sbin/sh

##########################################################################################
# MaxRegnerOS WebOS v1.1 - Uninstall Script
##########################################################################################

ui_print "- Uninstalling MaxRegnerOS WebOS v1.1..."

# Remove web OS data
rm -rf /data/maxregner_webos

# Reset system properties
resetprop ro.maxregner.webos.version ""
resetprop ro.maxregner.webos.enabled ""
resetprop ro.maxregner.device.optimized ""
resetprop ro.webview.default ""
resetprop ro.launcher.default ""

# Re-enable disabled services
pm enable com.samsung.android.bixby.agent 2>/dev/null
pm enable com.samsung.android.app.spage 2>/dev/null
pm enable com.samsung.android.game.gametools 2>/dev/null
pm enable com.samsung.android.gametuner.thin 2>/dev/null

# Reset animation scales
settings put global animator_duration_scale 1.0
settings put global transition_animation_scale 1.0
settings put global window_animation_scale 1.0

ui_print "✓ MaxRegnerOS WebOS v1.1 uninstalled successfully"
ui_print "✓ Reboot to complete removal"

