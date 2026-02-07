#pragma once

/*
 * Magisk Godzilla Configuration Header
 * Project Treble & Android 16 GSI Support
 * Samsung Galaxy Z Flip5 (SM-F731B/b5q) Optimized
 */

#define GODZILLA_VERSION "1.0.0"
#define GODZILLA_VERSION_CODE 1000

// Project Treble Configuration
#define TREBLE_ENABLED 1
#define VNDK_VERSION "35"  // Android 16 VNDK
#define VENDOR_API_LEVEL 35
#define SYSTEM_API_LEVEL 35

// Samsung Galaxy Z Flip5 (b5q) Configuration
#define DEVICE_CODENAME "b5q"
#define DEVICE_MODEL "SM-F731B"
#define DEVICE_BRAND "samsung"
#define DEVICE_MANUFACTURER "Samsung"
#define DEVICE_BOARD "lahaina"
#define DEVICE_PLATFORM "msm8998"
#define DEVICE_ARCH "arm64"

// Partition Configuration for Treble
#define SYSTEM_PARTITION "/dev/block/by-name/system"
#define VENDOR_PARTITION "/dev/block/by-name/vendor"
#define PRODUCT_PARTITION "/dev/block/by-name/product"
#define SYSTEM_EXT_PARTITION "/dev/block/by-name/system_ext"
#define ODM_PARTITION "/dev/block/by-name/odm"
#define BOOT_PARTITION "/dev/block/by-name/boot"
#define RECOVERY_PARTITION "/dev/block/by-name/recovery"

// GSI Configuration
#define GSI_SYSTEM_SIZE_GB 4
#define GSI_USERDATA_SIZE_GB 8
#define GSI_SUPPORT_DYNAMIC_PARTITIONS 1
#define GSI_SUPPORT_APEX 1
#define GSI_SUPPORT_COMPRESSED_APEX 1

// VINTF (Vendor Interface) Configuration
#define VINTF_MANIFEST_PATH "/vendor/etc/vintf/manifest.xml"
#define VINTF_MATRIX_PATH "/vendor/etc/vintf/compatibility_matrix.xml"
#define VINTF_FRAMEWORK_MANIFEST_PATH "/system/etc/vintf/manifest.xml"
#define VINTF_FRAMEWORK_MATRIX_PATH "/system/etc/vintf/compatibility_matrix.xml"

// Samsung Specific HAL Configuration
#define SAMSUNG_VENDOR_HAL_PATH "/vendor/lib64/hw"
#define SAMSUNG_CAMERA_HAL "camera.lahaina.so"
#define SAMSUNG_AUDIO_HAL "audio.primary.lahaina.so"
#define SAMSUNG_SENSORS_HAL "sensors.lahaina.so"
#define SAMSUNG_FINGERPRINT_HAL "fingerprint.fpc.so"
#define SAMSUNG_DISPLAY_HAL "hwcomposer.lahaina.so"

// Foldable Device Specific Configuration
#define FOLDABLE_DISPLAY_SUPPORT 1
#define DUAL_DISPLAY_SUPPORT 1
#define FLEX_MODE_SUPPORT 1
#define HINGE_SENSOR_SUPPORT 1

// Android 16 Specific Features
#define ANDROID_16_SUPPORT 1
#define ANDROID_16_API_LEVEL 35
#define ANDROID_16_SECURITY_PATCH "2024-12-01"
#define ANDROID_16_BUILD_VERSION "16.0.0"

// Magisk Godzilla Features
#define GODZILLA_TREBLE_BOOT_PATCH 1
#define GODZILLA_GSI_MANAGER 1
#define GODZILLA_VINTF_HANDLER 1
#define GODZILLA_VENDOR_OVERLAY 1
#define GODZILLA_SAMSUNG_OPTIMIZATION 1
#define GODZILLA_FOLDABLE_SUPPORT 1

// Security and Safety Features
#define GODZILLA_BACKUP_ORIGINAL_BOOT 1
#define GODZILLA_VERIFY_TREBLE_COMPLIANCE 1
#define GODZILLA_VALIDATE_VINTF 1
#define GODZILLA_ROLLBACK_SUPPORT 1

// Debug and Logging
#define GODZILLA_DEBUG_MODE 1
#define GODZILLA_VERBOSE_LOGGING 1
#define GODZILLA_LOG_PATH "/data/local/tmp/godzilla.log"

// Module System Configuration
#define GODZILLA_MODULE_PATH "/data/adb/modules_godzilla"
#define GODZILLA_TREBLE_MODULE_PATH "/data/adb/treble_modules"
#define GODZILLA_VENDOR_MODULE_PATH "/data/adb/vendor_modules"

// Build Configuration
#define GODZILLA_BUILD_TYPE "release"
#define GODZILLA_BUILD_DATE __DATE__
#define GODZILLA_BUILD_TIME __TIME__
#define GODZILLA_COMPILER_VERSION __VERSION__

#endif // GODZILLA_CONFIG_H
