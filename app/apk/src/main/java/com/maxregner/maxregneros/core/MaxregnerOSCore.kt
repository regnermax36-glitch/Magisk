package com.maxregner.maxregneros.core

import android.content.Context
import android.util.Log
import com.maxregner.maxregneros.utils.FileUtils
import com.maxregner.maxregneros.utils.RootUtils
import com.maxregner.maxregneros.utils.SystemUtils
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

/**
 * maxregnerOS Core System
 * Manages the core functionality of maxregnerOS including installation detection,
 * system validation, and core operations
 */
class MaxregnerOSCore(private val context: Context) {
    
    companion object {
        private const val TAG = "MaxregnerOSCore"
        
        // maxregnerOS installation paths
        const val MAXREGNEROS_DATA_DIR = "/data/maxregneros"
        const val MAXREGNEROS_SYSTEM_DIR = "$MAXREGNEROS_DATA_DIR/system"
        const val MAXREGNEROS_OVERLAY_DIR = "$MAXREGNEROS_DATA_DIR/overlay"
        const val MAXREGNEROS_CONFIG_DIR = "$MAXREGNEROS_DATA_DIR/config"
        const val MAXREGNEROS_THEMES_DIR = "$MAXREGNEROS_DATA_DIR/themes"
        const val MAXREGNEROS_MODULES_DIR = "$MAXREGNEROS_DATA_DIR/modules"
        const val MAXREGNEROS_BACKUP_DIR = "$MAXREGNEROS_DATA_DIR/backup"
        const val MAXREGNEROS_LOGS_DIR = "$MAXREGNEROS_DATA_DIR/logs"
        
        // Configuration files
        const val MAXREGNEROS_CONFIG_FILE = "$MAXREGNEROS_CONFIG_DIR/maxregneros.conf"
        const val MAXREGNEROS_VERSION_FILE = "$MAXREGNEROS_DATA_DIR/version"
        const val MAXREGNEROS_STATUS_FILE = "$MAXREGNEROS_DATA_DIR/status"
        
        // Init scripts
        const val MAXREGNEROS_INIT_DIR = "$MAXREGNEROS_DATA_DIR/init.d"
        
        // Version information
        const val MAXREGNEROS_VERSION = "1.0.0"
        const val MAXREGNEROS_VERSION_CODE = 100
        const val MAXREGNEROS_CODENAME = "Regner"
    }
    
    private var isInitialized = false
    private var installationStatus: InstallationStatus = InstallationStatus.UNKNOWN
    
    enum class InstallationStatus {
        UNKNOWN,
        NOT_INSTALLED,
        INSTALLED,
        CORRUPTED,
        OUTDATED
    }
    
    /**
     * Initialize the maxregnerOS core system
     */
    suspend fun initialize() = withContext(Dispatchers.IO) {
        try {
            Log.i(TAG, "Initializing maxregnerOS Core...")
            
            // Check root access
            if (!RootUtils.isRootAvailable()) {
                Log.w(TAG, "Root access not available - limited functionality")
            }
            
            // Detect installation status
            detectInstallationStatus()
            
            // Initialize logging
            initializeLogging()
            
            // Validate system integrity if installed
            if (installationStatus == InstallationStatus.INSTALLED) {
                validateSystemIntegrity()
            }
            
            isInitialized = true
            Log.i(TAG, "maxregnerOS Core initialized successfully")
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize maxregnerOS Core", e)
            throw e
        }
    }
    
    /**
     * Detect the current installation status of maxregnerOS
     */
    private suspend fun detectInstallationStatus() = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "Detecting maxregnerOS installation status...")
            
            // Check if main directory exists
            if (!File(MAXREGNEROS_DATA_DIR).exists()) {
                installationStatus = InstallationStatus.NOT_INSTALLED
                Log.i(TAG, "maxregnerOS not installed - main directory missing")
                return@withContext
            }
            
            // Check if version file exists
            val versionFile = File(MAXREGNEROS_VERSION_FILE)
            if (!versionFile.exists()) {
                installationStatus = InstallationStatus.CORRUPTED
                Log.w(TAG, "maxregnerOS installation corrupted - version file missing")
                return@withContext
            }
            
            // Check version compatibility
            val installedVersion = versionFile.readText().trim()
            if (installedVersion != MAXREGNEROS_VERSION) {
                installationStatus = InstallationStatus.OUTDATED
                Log.w(TAG, "maxregnerOS installation outdated - installed: $installedVersion, current: $MAXREGNEROS_VERSION")
                return@withContext
            }
            
            // Check essential files
            val essentialFiles = listOf(
                MAXREGNEROS_CONFIG_FILE,
                "$MAXREGNEROS_INIT_DIR/01-filesystem.sh",
                "$MAXREGNEROS_OVERLAY_DIR/system"
            )
            
            for (file in essentialFiles) {
                if (!File(file).exists()) {
                    installationStatus = InstallationStatus.CORRUPTED
                    Log.w(TAG, "maxregnerOS installation corrupted - missing essential file: $file")
                    return@withContext
                }
            }
            
            installationStatus = InstallationStatus.INSTALLED
            Log.i(TAG, "maxregnerOS installation detected and validated")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error detecting installation status", e)
            installationStatus = InstallationStatus.UNKNOWN
        }
    }
    
    /**
     * Validate the integrity of the maxregnerOS installation
     */
    suspend fun validateInstallation() = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "Validating maxregnerOS installation...")
            
            if (installationStatus != InstallationStatus.INSTALLED) {
                Log.w(TAG, "Cannot validate - maxregnerOS not properly installed")
                return@withContext false
            }
            
            // Check overlay mounts
            val overlayMounts = RootUtils.executeCommand("mount | grep overlay")
            if (overlayMounts.isNullOrEmpty()) {
                Log.w(TAG, "Overlay filesystems not mounted")
            }
            
            // Check init scripts
            validateInitScripts()
            
            // Check system properties
            validateSystemProperties()
            
            // Update status file
            updateStatusFile("validated")
            
            Log.i(TAG, "maxregnerOS installation validation completed")
            return@withContext true
            
        } catch (e: Exception) {
            Log.e(TAG, "Error validating installation", e)
            return@withContext false
        }
    }
    
    private fun validateInitScripts() {
        val initScripts = listOf(
            "01-filesystem.sh",
            "02-performance.sh", 
            "03-samsung.sh",
            "04-security.sh"
        )
        
        for (script in initScripts) {
            val scriptFile = File("$MAXREGNEROS_INIT_DIR/$script")
            if (scriptFile.exists() && scriptFile.canExecute()) {
                Log.d(TAG, "Init script validated: $script")
            } else {
                Log.w(TAG, "Init script missing or not executable: $script")
            }
        }
    }
    
    private fun validateSystemProperties() {
        val expectedProperties = mapOf(
            "ro.maxregneros.version" to MAXREGNEROS_VERSION,
            "ro.maxregneros.codename" to MAXREGNEROS_CODENAME,
            "ro.maxregneros.device" to "zflip5"
        )
        
        for ((prop, expectedValue) in expectedProperties) {
            val actualValue = SystemUtils.getSystemProperty(prop)
            if (actualValue == expectedValue) {
                Log.d(TAG, "System property validated: $prop = $actualValue")
            } else {
                Log.w(TAG, "System property mismatch: $prop expected=$expectedValue actual=$actualValue")
            }
        }
    }
    
    private fun initializeLogging() {
        try {
            val logsDir = File(MAXREGNEROS_LOGS_DIR)
            if (!logsDir.exists()) {
                logsDir.mkdirs()
            }
            
            // Create log files
            val logFiles = listOf("system.log", "installation.log", "performance.log")
            for (logFile in logFiles) {
                val file = File(logsDir, logFile)
                if (!file.exists()) {
                    file.createNewFile()
                }
            }
            
            Log.d(TAG, "Logging system initialized")
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize logging", e)
        }
    }
    
    private fun updateStatusFile(status: String) {
        try {
            val statusFile = File(MAXREGNEROS_STATUS_FILE)
            val timestamp = System.currentTimeMillis()
            val statusContent = """
                status=$status
                timestamp=$timestamp
                version=$MAXREGNEROS_VERSION
                version_code=$MAXREGNEROS_VERSION_CODE
                last_validation=${System.currentTimeMillis()}
            """.trimIndent()
            
            statusFile.writeText(statusContent)
            Log.d(TAG, "Status file updated: $status")
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to update status file", e)
        }
    }
    
    /**
     * Check if maxregnerOS is installed and functional
     */
    fun isMaxregnerOSInstalled(): Boolean {
        return installationStatus == InstallationStatus.INSTALLED
    }
    
    /**
     * Get the current installation status
     */
    fun getInstallationStatus(): InstallationStatus {
        return installationStatus
    }
    
    /**
     * Get installation status as human-readable string
     */
    fun getInstallationStatusString(): String {
        return when (installationStatus) {
            InstallationStatus.NOT_INSTALLED -> "Not Installed"
            InstallationStatus.INSTALLED -> "Installed and Active"
            InstallationStatus.CORRUPTED -> "Installation Corrupted"
            InstallationStatus.OUTDATED -> "Outdated Version"
            InstallationStatus.UNKNOWN -> "Unknown Status"
        }
    }
    
    /**
     * Get detailed system information
     */
    suspend fun getSystemInfo(): Map<String, String> = withContext(Dispatchers.IO) {
        val info = mutableMapOf<String, String>()
        
        try {
            info["maxregnerOS Version"] = MAXREGNEROS_VERSION
            info["Version Code"] = MAXREGNEROS_VERSION_CODE.toString()
            info["Codename"] = MAXREGNEROS_CODENAME
            info["Installation Status"] = getInstallationStatusString()
            info["Root Access"] = if (RootUtils.isRootAvailable()) "Available" else "Not Available"
            info["Device Model"] = SystemUtils.getDeviceModel()
            info["Device Codename"] = SystemUtils.getDeviceCodename()
            info["Android Version"] = SystemUtils.getAndroidVersion()
            info["API Level"] = SystemUtils.getApiLevel().toString()
            info["Architecture"] = SystemUtils.getArchitecture()
            info["Samsung Device"] = if (SystemUtils.isSamsungDevice()) "Yes" else "No"
            info["Z Flip5 Device"] = if (SystemUtils.isZFlip5()) "Yes" else "No"
            
            if (isMaxregnerOSInstalled()) {
                info["Overlay Mounts"] = getOverlayMountInfo()
                info["Init Scripts"] = getInitScriptInfo()
                info["Last Validation"] = getLastValidationTime()
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error getting system info", e)
            info["Error"] = e.message ?: "Unknown error"
        }
        
        return@withContext info
    }
    
    private fun getOverlayMountInfo(): String {
        return try {
            val mounts = RootUtils.executeCommand("mount | grep overlay | wc -l")
            "$mounts overlay mounts active"
        } catch (e: Exception) {
            "Unable to check"
        }
    }
    
    private fun getInitScriptInfo(): String {
        return try {
            val initDir = File(MAXREGNEROS_INIT_DIR)
            val scriptCount = initDir.listFiles()?.size ?: 0
            "$scriptCount init scripts"
        } catch (e: Exception) {
            "Unable to check"
        }
    }
    
    private fun getLastValidationTime(): String {
        return try {
            val statusFile = File(MAXREGNEROS_STATUS_FILE)
            if (statusFile.exists()) {
                val content = statusFile.readText()
                val timestampLine = content.lines().find { it.startsWith("last_validation=") }
                val timestamp = timestampLine?.substringAfter("=")?.toLongOrNull()
                if (timestamp != null) {
                    java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss", java.util.Locale.getDefault())
                        .format(java.util.Date(timestamp))
                } else {
                    "Unknown"
                }
            } else {
                "Never"
            }
        } catch (e: Exception) {
            "Unable to check"
        }
    }
    
    /**
     * Handle low memory situations
     */
    fun onLowMemory() {
        Log.w(TAG, "Low memory - performing cleanup")
        // Implement memory cleanup if needed
    }
    
    /**
     * Handle memory trim requests
     */
    fun onTrimMemory(level: Int) {
        Log.d(TAG, "Memory trim requested - level: $level")
        // Implement memory trimming based on level
    }
    
    /**
     * Cleanup resources
     */
    fun cleanup() {
        Log.i(TAG, "Cleaning up maxregnerOS Core resources")
        isInitialized = false
    }
    
    /**
     * Check if the core system is initialized
     */
    fun isInitialized(): Boolean {
        return isInitialized
    }
}
