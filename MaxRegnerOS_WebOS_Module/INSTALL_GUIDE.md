# MaxRegnerOS WebOS v1.1 - Installation Guide

## 🚀 Quick Start

Transform your Samsung Galaxy Z Flip5 into a web-based OS in just a few steps!

### ⚡ One-Click Installation (Recommended)

1. **Download** the module: `MaxRegnerOS_WebOS_v1.1.zip` (15KB)
2. **Open** Magisk Manager on your device
3. **Tap** Modules → Install from storage
4. **Select** the downloaded zip file
5. **Reboot** your device
6. **Enjoy** your new web-based OS!

---

## 📋 Prerequisites

### Device Requirements
- ✅ **Samsung Galaxy Z Flip5** (b5q)
- ✅ **Models**: SM-F731B, SM-F731U, SM-F731N
- ✅ **Android 13+** (One UI 5.1+)
- ✅ **Unlocked bootloader**
- ✅ **Root access** (Magisk v20.4+)

### Before Installation
- 🔄 **Create NANDROID backup** (highly recommended)
- 📱 **Charge device** to at least 50%
- 💾 **Free up 100MB** storage space
- 🌐 **Stable internet connection**

---

## 🛠️ Installation Methods

### Method 1: Magisk Manager (Easiest)

1. **Download Module**
   ```
   File: MaxRegnerOS_WebOS_v1.1.zip
   Size: ~15KB
   ```

2. **Install via Magisk**
   - Open Magisk Manager
   - Go to "Modules" section
   - Tap "Install from storage"
   - Navigate and select the zip file
   - Wait for installation to complete

3. **Reboot System**
   - Tap "Reboot" when prompted
   - Device will restart into web OS mode

### Method 2: TWRP Recovery

1. **Boot into TWRP**
   - Power off device
   - Hold Volume Up + Power button
   - Select TWRP recovery

2. **Flash Module**
   - Tap "Install"
   - Navigate to zip file location
   - Select `MaxRegnerOS_WebOS_v1.1.zip`
   - Swipe to confirm flash

3. **Reboot System**
   - Tap "Reboot System"
   - Device will boot into web OS

### Method 3: ADB Sideload

1. **Enable ADB**
   ```bash
   adb reboot recovery
   ```

2. **Sideload Module**
   ```bash
   adb sideload MaxRegnerOS_WebOS_v1.1.zip
   ```

3. **Reboot**
   ```bash
   adb reboot
   ```

---

## ✅ Post-Installation Setup

### First Boot
1. **Wait** for system to fully load (2-3 minutes)
2. **Web launcher** will automatically start
3. **Homepage** loads (default: Google)
4. **Setup complete** - start browsing!

### Verification
Check if installation was successful:

```bash
# Via ADB
adb shell getprop ro.maxregner.webos.version
# Should return: 1.1

# Via Terminal
getprop ro.maxregner.webos.enabled
# Should return: true
```

### Configuration
Access web OS settings:

```bash
# Check status
maxregner_launcher status

# View configuration
maxregner_launcher config

# Clear cache if needed
maxregner_launcher clear-cache
```

---

## 🎯 Usage Guide

### Web Launcher
- **Homepage**: Automatically loads on boot
- **Navigation**: Use standard web browser controls
- **Bookmarks**: Pre-configured popular sites
- **Web Apps**: Access like native applications

### Command Line Tools
```bash
# Start web launcher
maxregner_launcher start

# Launch specific web app
maxregner_launcher webapp "WhatsApp" "https://web.whatsapp.com"

# Add custom bookmark
maxregner_launcher bookmark "GitHub" "https://github.com"

# Web engine controls
webos_engine start
webos_engine clear-cache
webos_engine reset
```

### Pre-configured Web Apps
- 📧 **Gmail**: https://mail.google.com
- 💬 **WhatsApp Web**: https://web.whatsapp.com
- 🎵 **Spotify**: https://open.spotify.com
- 📺 **YouTube**: https://youtube.com
- 💼 **Office 365**: https://office.com
- 🎮 **Discord**: https://discord.com/app

---

## 🔧 Troubleshooting

### Common Issues

#### Module Not Active
```bash
# Check Magisk Manager
# Modules → MaxRegnerOS WebOS v1.1
# Ensure toggle is ON
```

#### Web Launcher Not Starting
```bash
# Reset web engine
webos_engine reset

# Restart launcher
maxregner_launcher start

# Set as default launcher
pm set-home-activity com.maxregner.webos.launcher/.MainActivity
```

#### Performance Issues
```bash
# Clear all caches
webos_engine clear-cache
maxregner_launcher clear-cache

# Check memory usage
cat /proc/meminfo | grep MemAvailable
```

#### Network Issues
```bash
# Check connectivity
ping google.com

# Reset network settings
settings put global airplane_mode_on 1
sleep 2
settings put global airplane_mode_on 0
```

### Log Files
- **Installation**: `/data/maxregner_webos/install.log`
- **Service**: `/data/maxregner_webos/service.log`
- **Init**: `/data/maxregner_webos/init.log`
- **Magisk**: `/cache/magisk.log`

### Recovery Mode
If system becomes unstable:

1. **Boot into TWRP**
2. **Disable module**:
   ```bash
   rm /data/adb/modules/maxregneros_webos/disable
   touch /data/adb/modules/maxregneros_webos/disable
   ```
3. **Reboot system**
4. **Fix issues** then re-enable

---

## 🗑️ Uninstallation

### Via Magisk Manager
1. Open Magisk Manager
2. Go to Modules section
3. Find "MaxRegnerOS WebOS v1.1"
4. Tap remove/uninstall
5. Reboot system

### Manual Removal
```bash
# Remove module directory
rm -rf /data/adb/modules/maxregneros_webos/

# Remove web OS data
rm -rf /data/maxregner_webos/

# Reboot
reboot
```

### Factory Reset (Last Resort)
If complete removal is needed:
1. Boot into recovery
2. Perform factory reset
3. Restore from backup

---

## 📊 Performance Metrics

### System Impact
- **RAM Usage**: +50-100MB
- **Storage**: 15KB module + 50MB runtime data
- **CPU**: Minimal impact during idle
- **Battery**: Varies based on web usage

### Optimization Features
- ✅ Memory management
- ✅ Cache optimization
- ✅ Network tuning
- ✅ CPU/GPU optimization
- ✅ Battery management

---

## 🔄 Updates

### Checking for Updates
```bash
# Check current version
getprop ro.maxregner.webos.version

# Module info
cat /data/adb/modules/maxregneros_webos/module.prop
```

### Update Process
1. Download new version
2. Install over existing (no uninstall needed)
3. Reboot system
4. Configuration preserved

---

## 🆘 Support

### Getting Help
- 📖 **Documentation**: Read README.md and CHANGELOG.md
- 🐛 **Issues**: Report bugs with log files
- 💬 **Community**: Android modding forums
- 📧 **Contact**: Include device info and logs

### Reporting Issues
Include the following information:
- Device model and Android version
- Magisk version
- Module version
- Log files from `/data/maxregner_webos/`
- Steps to reproduce the issue

---

## ⚠️ Important Notes

### Warnings
- 🔄 **Always backup** before installation
- 📱 **Device specific** - optimized for Galaxy Z Flip5
- 🔋 **Battery usage** may increase with heavy web usage
- 📊 **Data consumption** will increase significantly
- 🛡️ **Security** - web-based OS has different security model

### Compatibility
- ✅ **Tested**: Samsung Galaxy Z Flip5 (b5q)
- ❓ **Untested**: Other Samsung devices
- ❌ **Not supported**: Non-Samsung devices

### Legal
- This module is provided as-is
- Use at your own risk
- No warranty provided
- Educational/development purposes

---

**MaxRegnerOS WebOS v1.1** - Welcome to the future of mobile computing! 🌐📱✨

