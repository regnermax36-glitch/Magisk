#pragma once

#include <string>
#include <vector>
#include <memory>
#include <map>
#include "../../../godzilla_config.h"

namespace godzilla {

class TrebleManager {
public:
    struct TrebleInfo {
        bool treble_enabled;
        bool vndk_lite;
        bool vndk_full;
        std::string vndk_version;
        std::string vendor_api_level;
        std::string system_api_level;
        bool dynamic_partitions;
        bool apex_supported;
    };

    struct VintfInfo {
        std::string manifest_path;
        std::string matrix_path;
        std::vector<std::string> hal_interfaces;
        std::map<std::string, std::string> vendor_properties;
        bool vintf_valid;
    };

    struct GSICompatibility {
        bool gsi_supported;
        bool android_16_compatible;
        std::string required_vndk;
        std::vector<std::string> missing_hals;
        std::vector<std::string> incompatible_vendors;
    };

    TrebleManager();
    ~TrebleManager();

    // Core Treble Detection
    bool detectTrebleSupport();
    TrebleInfo getTrebleInfo();
    bool isVndkCompliant();
    std::string getVndkVersion();

    // VINTF Management
    bool parseVintfManifest();
    bool validateVintfCompatibility();
    VintfInfo getVintfInfo();
    bool updateVintfForGSI();

    // GSI Compatibility
    GSICompatibility checkGSICompatibility();
    bool prepareForGSI();
    bool validateAndroid16GSI();
    bool patchVendorForGSI();

    // Samsung Specific
    bool detectSamsungVendor();
    bool patchSamsungHALs();
    bool handleSamsungSecurity();
    bool optimizeForFoldable();

    // Device Specific (b5q)
    bool detectB5QDevice();
    bool configureB5QPartitions();
    bool setupB5QVendorOverlay();
    bool enableB5QFoldableFeatures();

    // Boot Image Management
    bool patchBootForTreble(const std::string& boot_path);
    bool injectTrebleSupport(const std::string& boot_path);
    bool validateTrebleBoot(const std::string& boot_path);

    // Module System Integration
    bool setupTrebleModulePaths();
    bool validateModuleTrebleCompat(const std::string& module_path);
    bool installTrebleModule(const std::string& module_path);

    // Safety and Backup
    bool backupOriginalBoot();
    bool createRollbackPoint();
    bool validateSystemIntegrity();
    bool restoreFromBackup();

    // Logging and Debug
    void enableVerboseLogging();
    void logTrebleStatus();
    void dumpTrebleInfo();
    std::string getLastError();

private:
    TrebleInfo treble_info_;
    VintfInfo vintf_info_;
    GSICompatibility gsi_compat_;
    std::string last_error_;
    bool verbose_logging_;

    // Internal helper methods
    bool readSystemProperty(const std::string& prop, std::string& value);
    bool fileExists(const std::string& path);
    bool parseXMLFile(const std::string& path);
    bool executeCommand(const std::string& cmd, std::string& output);
    bool mountPartition(const std::string& partition, const std::string& mount_point);
    bool unmountPartition(const std::string& mount_point);
    
    // Treble specific helpers
    bool checkTrebleProperty();
    bool checkVndkProperty();
    bool checkDynamicPartitions();
    bool checkApexSupport();
    
    // VINTF specific helpers
    bool parseManifestXML(const std::string& path);
    bool parseMatrixXML(const std::string& path);
    bool validateHALInterface(const std::string& interface);
    
    // Samsung specific helpers
    bool detectSamsungBootloader();
    bool checkSamsungSecurity();
    bool patchSamsungSEPolicy();
    
    // GSI specific helpers
    bool checkGSIRequirements();
    bool validateVendorImage();
    bool prepareVendorOverlay();
};

// Utility functions
namespace treble_utils {
    bool isTrebleDevice();
    std::string getDeviceCodename();
    std::string getVendorVersion();
    bool isGSICompatible();
    bool isAndroid16Ready();
}

} // namespace godzilla
