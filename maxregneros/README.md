# maxregnerOS - Custom OS Redesigner for Samsung Galaxy Z Flip5

maxregnerOS is a custom OS redesigner built on top of Magisk that completely restructures the Samsung Galaxy Z Flip5 filesystem and UI while maintaining full TWRP compatibility.

## Features

### 🔧 Filesystem Restructuring
- **Overlay Filesystem**: Uses overlayfs to create a non-destructive filesystem overlay
- **Custom Directory Structure**: Reorganizes system, vendor, and product partitions
- **Modular Architecture**: Clean separation of system components
- **Backup & Restore**: Automatic backup of original system files

### 🎨 UI Redesign
- **Custom SystemUI**: Redesigned status bar and notification panel
- **maxregnerOS Launcher**: Custom launcher optimized for Z Flip5
- **Custom Framework**: Modified Android framework with maxregnerOS branding
- **Theme System**: Built-in theming engine with custom icons and animations

### ⚡ Performance Optimizations
- **CPU Governor Tweaks**: Optimized CPU scaling for better performance
- **GPU Optimizations**: Enhanced graphics performance
- **Memory Management**: Improved RAM and storage management
- **I/O Scheduler**: Optimized disk I/O for faster app loading

### 🔒 Security Enhancements
- **Knox Removal**: Disables Samsung Knox security framework
- **Bloatware Removal**: Removes unnecessary Samsung services
- **Custom Security**: Implements maxregnerOS security features
- **Root Management**: Maintains Magisk root capabilities

### 📱 Samsung Z Flip5 Specific
- **Foldable Display Optimization**: Enhanced dual-screen support
- **Battery Optimization**: Improved battery life for dual displays
- **Samsung Service Management**: Selective Samsung service control
- **Hardware-Specific Tweaks**: Optimizations for Snapdragon 8 Gen 2

## Installation

### Prerequisites
- Samsung Galaxy Z Flip5 (SM-F731*)
- Unlocked bootloader
- TWRP recovery installed
- Android 10.0 or higher
- At least 2GB free storage space

### Installation Steps

1. **Download maxregnerOS**
   ```bash
   # Build from source
   cd maxregneros/
   python3 build_maxregneros.py
   ```
   Or download the pre-built ZIP from releases.

2. **Boot into TWRP**
   - Power off your device
   - Hold Volume Up + Power to enter recovery mode

3. **Create Backup** (Recommended)
   - In TWRP, go to Backup
   - Select Boot, System, Vendor, and Data
   - Swipe to backup

4. **Install maxregnerOS**
   - In TWRP, go to Install
   - Navigate to the maxregnerOS ZIP file
   - Swipe to confirm flash
   - Wait for installation to complete

5. **Reboot**
   - Reboot to system
   - First boot may take 5-10 minutes

## File Structure

```
maxregneros/
├── installer.sh              # Main installation script
├── maxregneros_functions.sh   # Core functionality functions
├── addon.d.sh                # OTA survival script
├── uninstaller.sh            # Uninstallation script
├── build_maxregneros.py       # Build system
└── README.md                 # This file
```

## Build System

The build system creates flashable ZIP files compatible with TWRP:

```bash
# Build installer and uninstaller
python3 build_maxregneros.py

# Output files
output/
├── maxregnerOS-v1.0.0-zflip5.zip        # Main installer
└── maxregnerOS-uninstaller-v1.0.0.zip   # Uninstaller
```

## Configuration

### Build Properties
maxregnerOS adds the following system properties:
- `ro.maxregneros.version`: OS version
- `ro.maxregneros.codename`: Release codename
- `ro.maxregneros.device`: Target device
- `ro.maxregneros.build.date`: Build date
- `ro.maxregneros.build.type`: Build type

### Performance Tweaks
- CPU governors set to performance mode
- GPU governor optimized for gaming
- I/O scheduler set to deadline
- Memory management optimized
- Swappiness reduced to 60

### UI Customizations
- Custom boot animation
- Redesigned SystemUI with maxregnerOS branding
- Custom launcher with Z Flip5 optimizations
- Modified framework with performance enhancements

## Uninstallation

To remove maxregnerOS and restore your original system:

1. **Boot into TWRP**
2. **Flash Uninstaller**
   - Install the uninstaller ZIP
   - This will remove all maxregnerOS modifications
3. **Reboot**
   - Your device will be restored to its original state

## Compatibility

### Supported Devices
- Samsung Galaxy Z Flip5 (SM-F731B, SM-F731U, SM-F731N)
- Android 10.0 - 14.0
- One UI 5.0 - 6.0

### Tested Configurations
- TWRP 3.7.0+
- Magisk 25.0+
- Stock Samsung firmware

## Troubleshooting

### Boot Issues
If your device doesn't boot after installation:
1. Boot into TWRP
2. Flash the uninstaller ZIP
3. Restore from backup if needed

### Performance Issues
- Check CPU governor settings in `/sys/devices/system/cpu/`
- Verify overlay mounts with `mount | grep overlay`
- Check logs in `/data/maxregneros/logs/`

### UI Issues
- Clear SystemUI cache: `pm clear com.android.systemui`
- Restart SystemUI: `killall com.android.systemui`
- Check overlay files in `/data/maxregneros/overlay/`

## Development

### Building from Source
```bash
# Clone the repository
git clone https://github.com/regnermax36-glitch/Magisk.git
cd Magisk/maxregneros/

# Build maxregnerOS
python3 build_maxregneros.py

# Test installation (requires device)
adb push output/maxregnerOS-v1.0.0-zflip5.zip /sdcard/
```

### Adding Custom UI Components
1. Place APK files in `maxregneros/ui/`
2. Add installation logic to `install_custom_systemui()`
3. Update permissions in `maxregneros-systemui.xml`

### Adding Performance Tweaks
1. Edit `apply_performance_tweaks()` function
2. Add new init.d scripts in `/data/maxregneros/init.d/`
3. Test on device before committing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on Samsung Galaxy Z Flip5
5. Submit a pull request

## License

This project is licensed under the GPL v3 License - see the [LICENSE](../LICENSE) file for details.

## Disclaimer

⚠️ **WARNING**: This software modifies your device's system files. Use at your own risk.

- Always create a full backup before installation
- This may void your warranty
- The developers are not responsible for bricked devices
- Only install on supported devices

## Credits

- **Magisk**: Base framework by topjohnwu
- **TWRP**: Recovery environment
- **Samsung**: Original firmware and drivers
- **maxregner**: maxregnerOS development and customization

## Support

For support and updates:
- GitHub Issues: Report bugs and feature requests
- XDA Forums: Community discussion
- Telegram: @maxregnerOS (coming soon)

---

**maxregnerOS v1.0.0** - Transforming your Samsung Galaxy Z Flip5 experience
