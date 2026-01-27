# MaxRegnerOS WebOS v1.1 - Magisk Module

Transform your Samsung Galaxy Z Flip5 (b5q) into an ultra web-based operating system similar to Puffin OS.

## 🚀 Features

- **Ultra-lightweight**: Only 30MB compiled footprint
- **Web-based interface**: Full web browser as primary interface
- **Samsung OS v1.1**: Optimized for Samsung Galaxy Z Flip5
- **Puffin OS-like experience**: Cloud-based web applications
- **TWRP installable**: Easy installation via TWRP recovery
- **Magisk integration**: Systemless modification, easily reversible

## 📱 Device Compatibility

- **Primary**: Samsung Galaxy Z Flip5 (b5q)
- **Models**: SM-F731B, SM-F731U, SM-F731N
- **Android**: 13+ (One UI 5.1+)
- **Magisk**: v20.4+

## 🛠️ Installation

### Prerequisites
1. Unlocked bootloader
2. TWRP recovery installed
3. Magisk v20.4+ installed
4. Root access

### Installation Steps
1. Download `MaxRegnerOS_WebOS_v1.1.zip`
2. Boot into TWRP recovery
3. Flash the module zip file
4. Reboot system
5. Open Magisk Manager
6. Verify module is active

### Alternative Installation (Magisk Manager)
1. Open Magisk Manager
2. Go to Modules section
3. Tap "Install from storage"
4. Select `MaxRegnerOS_WebOS_v1.1.zip`
5. Reboot when prompted

## 🌐 Usage

After installation and reboot:

1. **Web Launcher**: Your device will boot into web-based launcher
2. **Homepage**: Default homepage is Google (configurable)
3. **Web Apps**: Access web applications like native apps
4. **Bookmarks**: Pre-configured popular web services
5. **Kiosk Mode**: Optional full-screen web browsing

### Command Line Tools

```bash
# Start web launcher
maxregner_launcher start

# Launch specific web app
maxregner_launcher webapp "WhatsApp" "https://web.whatsapp.com"

# Add bookmark
maxregner_launcher bookmark "GitHub" "https://github.com"

# Check status
maxregner_launcher status

# Clear cache
maxregner_launcher clear-cache

# Start web engine
webos_engine start

# Clear web cache
webos_engine clear-cache

# Reset web engine
webos_engine reset
```

## ⚙️ Configuration

### Web OS Configuration
Location: `/data/maxregner_webos/config.json`

```json
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
```

### System Properties
The module sets various system properties for optimization:

- `ro.maxregner.webos.version=1.1`
- `ro.maxregner.webos.enabled=true`
- `ro.maxregner.device.optimized=b5q`
- `ro.webview.default=com.maxregner.webos.webview`
- `ro.launcher.default=com.maxregner.webos.launcher`

## 📋 Pre-configured Web Apps

- **Google Services**: Gmail, Drive, Photos, Maps
- **Social**: WhatsApp Web, Telegram Web, Discord
- **Entertainment**: YouTube, Spotify, Netflix
- **Productivity**: Office 365, Google Workspace
- **Development**: GitHub, CodePen, JSFiddle

## 🔧 Troubleshooting

### Common Issues

1. **Module not working after reboot**
   - Check Magisk Manager for module status
   - Ensure device compatibility
   - Try reinstalling the module

2. **Web launcher not starting**
   ```bash
   # Reset web engine
   webos_engine reset
   
   # Restart launcher
   maxregner_launcher start
   ```

3. **Performance issues**
   ```bash
   # Clear cache
   webos_engine clear-cache
   maxregner_launcher clear-cache
   ```

4. **Default launcher not set**
   ```bash
   # Manually set launcher
   pm set-home-activity com.maxregner.webos.launcher/.MainActivity
   ```

### Log Files
- Installation: `/data/maxregner_webos/install.log`
- Service: `/data/maxregner_webos/service.log`
- Magisk: `/cache/magisk.log`

## 🗑️ Uninstallation

### Via Magisk Manager
1. Open Magisk Manager
2. Go to Modules section
3. Find "MaxRegnerOS WebOS v1.1"
4. Tap remove/uninstall
5. Reboot system

### Manual Uninstallation
1. Boot into TWRP
2. Mount system partition
3. Delete module files from `/data/adb/modules/maxregneros_webos/`
4. Reboot system

## ⚠️ Warnings

- **Backup**: Always create a full NANDROID backup before installation
- **Compatibility**: Primarily tested on Samsung Galaxy Z Flip5 (b5q)
- **Performance**: May affect battery life due to constant web browsing
- **Data Usage**: Increased data consumption due to web-based interface
- **Security**: Web-based OS may have different security implications

## 🔄 Updates

To update the module:
1. Download new version
2. Flash over existing installation
3. Reboot system
4. Configuration and data are preserved

## 📞 Support

- **Issues**: Report on GitHub repository
- **Compatibility**: Test on your device before daily use
- **Logs**: Include log files when reporting issues

## 📄 License

This module is provided as-is for educational and development purposes.

## 🙏 Credits

- **Magisk**: topjohnwu for the Magisk framework
- **Samsung**: For the base Android system
- **Chromium**: For web rendering engine
- **Community**: Android modding community

---

**MaxRegnerOS WebOS v1.1** - Transform your Samsung Galaxy Z Flip5 into a web-based powerhouse! 🚀

