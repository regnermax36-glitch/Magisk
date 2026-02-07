#pragma once

#include <string>
#include <vector>
#include <memory>
#include "../../../godzilla_config.h"

namespace godzilla {

class GSIManager {
public:
    struct GSIInfo {
        std::string gsi_path;
        std::string gsi_version;
        std::string android_version;
        std::string api_level;
        std::string architecture;
        bool has_gms;
        bool is_android_16;
        size_t size_bytes;
    };

    struct InstallationConfig {
        bool wipe_userdata;
        bool disable_verity;
        bool disable_verification;
        bool enable_root;
        std::string userdata_size;
        std::vector<std::string> additional_partitions;
    };

    struct InstallationStatus {
        bool success;
        std::string error_message;
        std::vector<std::string> warnings;
        std::string installation_log;
    };

    GSIManager();
    ~GSIManager();

    // GSI Detection and Validation
    bool detectGSIImage(const std::string& gsi_path);
    GSIInfo analyzeGSI(const std::string& gsi_path);
    bool validateGSICompatibility(const GSIInfo& gsi_info);
    bool isAndroid16GSI(const std::string& gsi_path);

    // Device Compatibility
    bool checkDeviceCompatibility();
    bool validatePartitionLayout();
    bool checkAvailableSpace(size_t required_space);
    bool verifyBootloaderUnlocked();

    // Installation Preparation
    bool prepareInstallation(const InstallationConfig& config);
    bool backupCurrentSystem();
    bool createInstallationPlan(const GSIInfo& gsi_info, const InstallationConfig& config);
    bool validateInstallationPlan();

    // GSI Installation
    InstallationStatus installGSI(const std::string& gsi_path, const InstallationConfig& config);
    bool flashGSIImage(const std::string& gsi_path);
    bool configureGSIBoot();
    bool setupGSIUserdata(const std::string& size);

    // Post-Installation
    bool configureGSIEnvironment();
    bool installGodzillaModules();
    bool setupTrebleCompatibility();
    bool validateGSIBoot();

    // Samsung Specific
    bool handleSamsungGSI();
    bool patchSamsungVendor();
    bool configureSamsungHALs();
    bool setupFoldableGSI();

    // Android 16 Specific
    bool configureAndroid16Features();
    bool setupAndroid16Security();
    bool enableAndroid16APIs();
    bool configureAndroid16VNDK();

    // Recovery and Rollback
    bool createRecoveryPoint();
    bool rollbackGSI();
    bool restoreOriginalSystem();
    bool repairGSIInstallation();

    // Utilities
    std::string getGSIStatus();
    std::vector<std::string> listInstalledGSIs();
    bool removeGSI();
    bool switchGSI(const std::string& gsi_name);

    // Logging and Debug
    void enableVerboseLogging();
    std::string getInstallationLog();
    std::string getLastError();

private:
    GSIInfo current_gsi_;
    InstallationConfig current_config_;
    std::string last_error_;
    std::string installation_log_;
    bool verbose_logging_;

    // Internal helper methods
    bool executeCommand(const std::string& cmd, std::string& output);
    bool mountPartition(const std::string& partition, const std::string& mount_point);
    bool unmountPartition(const std::string& mount_point);
    bool fileExists(const std::string& path);
    size_t getFileSize(const std::string& path);
    bool copyFile(const std::string& src, const std::string& dst);
    
    // GSI specific helpers
    bool extractGSIInfo(const std::string& gsi_path, GSIInfo& info);
    bool validateGSIFormat(const std::string& gsi_path);
    bool checkGSISignature(const std::string& gsi_path);
    
    // Installation helpers
    bool preparePartitions();
    bool flashSystemImage(const std::string& image_path);
    bool updateBootImage();
    bool configureVendorOverlay();
    
    // Samsung specific helpers
    bool detectSamsungDevice();
    bool getSamsungVendorVersion();
    bool patchSamsungSEPolicy();
    
    // Android 16 specific helpers
    bool validateAndroid16Requirements();
    bool setupAndroid16Partitions();
    bool configureAndroid16Properties();
};

// Utility functions
namespace gsi_utils {
    bool isGSISupported();
    std::string getSystemPartitionPath();
    std::string getVendorPartitionPath();
    bool hasEnoughSpace(size_t required_gb);
    std::vector<std::string> getAvailableGSIs();
}

} // namespace godzilla
