#!/usr/bin/env python3
############################################
# maxregnerOS Build Script
# Builds flashable ZIP for TWRP installation
############################################

import os
import sys
import shutil
import zipfile
import subprocess
from pathlib import Path

def print_header(text):
    print(f"\n{'='*50}")
    print(f" {text}")
    print(f"{'='*50}\n")

def print_info(text):
    print(f"[INFO] {text}")

def print_error(text):
    print(f"[ERROR] {text}")
    sys.exit(1)

def create_directory(path):
    """Create directory if it doesn't exist"""
    Path(path).mkdir(parents=True, exist_ok=True)
    print_info(f"Created directory: {path}")

def copy_file(src, dst):
    """Copy file with error handling"""
    try:
        shutil.copy2(src, dst)
        print_info(f"Copied: {src} -> {dst}")
    except Exception as e:
        print_error(f"Failed to copy {src}: {e}")

def copy_directory(src, dst):
    """Copy directory recursively"""
    try:
        shutil.copytree(src, dst, dirs_exist_ok=True)
        print_info(f"Copied directory: {src} -> {dst}")
    except Exception as e:
        print_error(f"Failed to copy directory {src}: {e}")

def create_update_binary():
    """Create update-binary script for TWRP"""
    update_binary_content = '''#!/sbin/sh
############################################
# maxregnerOS Update Binary
# TWRP Installation Script
############################################

OUTFD=$2
ZIPFILE=$3

# Extract installer
INSTALLER=/tmp/maxregneros_installer
rm -rf $INSTALLER
mkdir -p $INSTALLER
cd $INSTALLER

# Extract the ZIP
unzip -o "$ZIPFILE"

# Set permissions
chmod -R 755 $INSTALLER

# Run the installer
exec sh $INSTALLER/maxregneros/installer.sh "$@"
'''
    return update_binary_content

def create_updater_script():
    """Create updater-script for compatibility"""
    updater_script_content = '''# maxregnerOS Installer
# This script is executed by the update-binary
ui_print("Installing maxregnerOS...");
ui_print("Please wait...");
'''
    return updater_script_content

def build_maxregneros_zip():
    """Main build function"""
    print_header("maxregnerOS Build System")
    
    # Define paths
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    build_dir = script_dir / "build"
    output_dir = script_dir / "output"
    
    # Clean and create build directories
    if build_dir.exists():
        shutil.rmtree(build_dir)
    create_directory(build_dir)
    create_directory(output_dir)
    
    # Create installer structure
    installer_dir = build_dir / "installer"
    create_directory(installer_dir)
    create_directory(installer_dir / "META-INF" / "com" / "google" / "android")
    create_directory(installer_dir / "assets")
    create_directory(installer_dir / "maxregneros")
    create_directory(installer_dir / "lib" / "arm64-v8a")
    create_directory(installer_dir / "lib" / "armeabi-v7a")
    
    print_info("Created installer directory structure")
    
    # Copy Magisk assets
    magisk_scripts = [
        "util_functions.sh",
        "boot_patch.sh",
        "addon.d.sh"
    ]
    
    for script in magisk_scripts:
        src = project_root / "scripts" / script
        if src.exists():
            copy_file(src, installer_dir / "assets" / script)
    
    # Copy maxregnerOS files
    maxregneros_files = [
        "installer.sh",
        "maxregneros_functions.sh", 
        "addon.d.sh",
        "uninstaller.sh"
    ]
    
    for file in maxregneros_files:
        src = script_dir / file
        if src.exists():
            copy_file(src, installer_dir / "maxregneros" / file)
    
    # Create update-binary
    update_binary_path = installer_dir / "META-INF" / "com" / "google" / "android" / "update-binary"
    with open(update_binary_path, 'w') as f:
        f.write(create_update_binary())
    os.chmod(update_binary_path, 0o755)
    print_info("Created update-binary")
    
    # Create updater-script
    updater_script_path = installer_dir / "META-INF" / "com" / "google" / "android" / "updater-script"
    with open(updater_script_path, 'w') as f:
        f.write(create_updater_script())
    print_info("Created updater-script")
    
    # Copy Magisk binaries (if available)
    magisk_lib_dir = project_root / "lib"
    if magisk_lib_dir.exists():
        copy_directory(magisk_lib_dir, installer_dir / "lib")
    
    # Create module.prop
    module_prop_content = '''id=maxregneros
name=maxregnerOS
version=v1.0.0
versionCode=100
author=maxregner
description=Custom OS redesigner for Samsung Galaxy Z Flip5 - Restructures filesystem and UI while maintaining TWRP compatibility
'''
    
    with open(installer_dir / "module.prop", 'w') as f:
        f.write(module_prop_content)
    print_info("Created module.prop")
    
    # Create placeholder directories for UI components
    ui_dirs = [
        "maxregneros/ui",
        "maxregneros/themes/icons",
        "maxregneros/framework"
    ]
    
    for ui_dir in ui_dirs:
        create_directory(installer_dir / ui_dir)
    
    # Create sample theme files
    create_sample_theme_files(installer_dir)
    
    # Create the ZIP file
    zip_name = f"maxregnerOS-v1.0.0-zflip5.zip"
    zip_path = output_dir / zip_name
    
    print_info(f"Creating ZIP file: {zip_name}")
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(installer_dir):
            for file in files:
                file_path = Path(root) / file
                arc_path = file_path.relative_to(installer_dir)
                zipf.write(file_path, arc_path)
    
    print_header("Build Complete!")
    print_info(f"Output: {zip_path}")
    print_info(f"Size: {zip_path.stat().st_size / 1024 / 1024:.2f} MB")
    print_info("Ready for TWRP installation!")

def create_sample_theme_files(installer_dir):
    """Create sample theme and UI files"""
    
    # Create sample boot animation descriptor
    bootanim_desc = '''1080 2640 30
p 1 0 part0
p 0 0 part1
'''
    
    bootanim_dir = installer_dir / "maxregneros" / "themes"
    create_directory(bootanim_dir)
    
    with open(bootanim_dir / "desc.txt", 'w') as f:
        f.write(bootanim_desc)
    
    # Create sample SystemUI configuration
    systemui_config = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- maxregnerOS SystemUI Configuration -->
    <string name="config_statusBarComponent">com.maxregneros.systemui.statusbar.phone.StatusBar</string>
    <bool name="config_enableCustomTheme">true</bool>
    <color name="maxregneros_accent_color">#FF6B35</color>
    <color name="maxregneros_primary_color">#1A1A1A</color>
</resources>
'''
    
    ui_dir = installer_dir / "maxregneros" / "ui"
    with open(ui_dir / "systemui_config.xml", 'w') as f:
        f.write(systemui_config)
    
    print_info("Created sample theme files")

def create_uninstaller_zip():
    """Create uninstaller ZIP"""
    print_header("Creating maxregnerOS Uninstaller")
    
    script_dir = Path(__file__).parent
    output_dir = script_dir / "output"
    uninstaller_dir = script_dir / "build" / "uninstaller"
    
    create_directory(uninstaller_dir)
    create_directory(uninstaller_dir / "META-INF" / "com" / "google" / "android")
    create_directory(uninstaller_dir / "assets")
    create_directory(uninstaller_dir / "maxregneros")
    
    # Copy utility functions
    copy_file(script_dir.parent / "scripts" / "util_functions.sh", 
              uninstaller_dir / "assets" / "util_functions.sh")
    
    # Copy maxregnerOS functions and uninstaller
    copy_file(script_dir / "maxregneros_functions.sh", 
              uninstaller_dir / "maxregneros" / "maxregneros_functions.sh")
    copy_file(script_dir / "uninstaller.sh", 
              uninstaller_dir / "maxregneros" / "uninstaller.sh")
    
    # Create uninstaller update-binary
    uninstaller_update_binary = '''#!/sbin/sh
OUTFD=$2
ZIPFILE=$3

INSTALLER=/tmp/maxregneros_uninstaller
rm -rf $INSTALLER
mkdir -p $INSTALLER
cd $INSTALLER

unzip -o "$ZIPFILE"
chmod -R 755 $INSTALLER

exec sh $INSTALLER/maxregneros/uninstaller.sh "$@"
'''
    
    update_binary_path = uninstaller_dir / "META-INF" / "com" / "google" / "android" / "update-binary"
    with open(update_binary_path, 'w') as f:
        f.write(uninstaller_update_binary)
    os.chmod(update_binary_path, 0o755)
    
    # Create uninstaller ZIP
    zip_name = "maxregnerOS-uninstaller-v1.0.0.zip"
    zip_path = output_dir / zip_name
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(uninstaller_dir):
            for file in files:
                file_path = Path(root) / file
                arc_path = file_path.relative_to(uninstaller_dir)
                zipf.write(file_path, arc_path)
    
    print_info(f"Uninstaller created: {zip_path}")

if __name__ == "__main__":
    try:
        build_maxregneros_zip()
        create_uninstaller_zip()
        print_header("All builds completed successfully!")
    except KeyboardInterrupt:
        print_error("Build interrupted by user")
    except Exception as e:
        print_error(f"Build failed: {e}")
