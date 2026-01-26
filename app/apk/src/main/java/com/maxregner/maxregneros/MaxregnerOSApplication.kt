package com.maxregner.maxregneros

import android.app.Application
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.lifecycle.ProcessLifecycleOwner
import com.maxregner.maxregneros.core.MaxregnerOSCore
import com.maxregner.maxregneros.services.MaxregnerOSService
import com.maxregner.maxregneros.utils.RootUtils
import com.maxregner.maxregneros.utils.SystemUtils
import com.maxregner.maxregneros.utils.PreferenceUtils
import com.maxregner.maxregneros.core.Config
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/**
 * maxregnerOS Application Class
 * Main application entry point that initializes the entire maxregnerOS system
 */
class MaxregnerOSApplication : Application() {
    
    companion object {
        private const val TAG = "MaxregnerOSApp"
        
        @JvmStatic
        lateinit var instance: MaxregnerOSApplication
            private set
            
        @JvmStatic
        val appContext: Context get() = instance.applicationContext
        
        @JvmStatic
        val applicationScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    }
    
    lateinit var core: MaxregnerOSCore
        private set
    
    override fun onCreate() {
        super.onCreate()
        instance = this
        
        Log.i(TAG, "maxregnerOS Application starting...")
        Log.i(TAG, "Version: ${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})")
        Log.i(TAG, "Build Type: ${BuildConfig.BUILD_TYPE}")
        
        // Initialize core components
        initializeCore()
        
        // Initialize configuration
        Config.initialize(this)
        
        // Start background service
        startMaxregnerOSService()
        
        // Apply system tweaks if root is available
        if (RootUtils.isRootAvailable()) {
            applySystemTweaks()
        }
        
        // Setup lifecycle observer
        ProcessLifecycleOwner.get().lifecycle.addObserver(MaxregnerOSLifecycleObserver())
        
        Log.i(TAG, "maxregnerOS Application initialized successfully")
    }
    
    private fun initializeCore() {
        try {
            core = MaxregnerOSCore(this)
            core.initialize()
            
            // Check if maxregnerOS is installed
            if (core.isMaxregnerOSInstalled()) {
                Log.i(TAG, "maxregnerOS installation detected")
                core.validateInstallation()
                
                // Load user preferences
                PreferenceUtils.loadPreferences(this)
                
                // Apply saved configurations
                applySavedConfigurations()
                
            } else {
                Log.w(TAG, "maxregnerOS not installed - running in setup mode")
                // Set default preferences for first run
                PreferenceUtils.setDefaultPreferences(this)
            }
            
        } catch (Exception e) {
            Log.e(TAG, "Failed to initialize maxregnerOS core", e)
        }
    }
    
    private fun startMaxregnerOSService() {
        try {
            val serviceIntent = Intent(this, MaxregnerOSService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }
            Log.i(TAG, "maxregnerOS service started")
        } catch (Exception e) {
            Log.e(TAG, "Failed to start maxregnerOS service", e)
        }
    }
    
    private fun applySystemTweaks() {
        applicationScope.launch(Dispatchers.IO) {
            try {
                Log.i(TAG, "Applying system tweaks...")
                
                // Apply performance tweaks
                SystemUtils.applyPerformanceTweaks()
                
                // Apply UI tweaks
                SystemUtils.applyUITweaks()
                
                // Apply Samsung-specific tweaks for Z Flip5
                if (SystemUtils.isSamsungDevice() && SystemUtils.isZFlip5()) {
                    SystemUtils.applySamsungZFlip5Tweaks()
                } else if (SystemUtils.isSamsungDevice()) {
                    SystemUtils.applySamsungTweaks()
                }
                
                // Apply security tweaks
                SystemUtils.applySecurityTweaks()
                
                // Apply filesystem tweaks
                SystemUtils.applyFilesystemTweaks()
                
                Log.i(TAG, "System tweaks applied successfully")
                
            } catch (Exception e) {
                Log.e(TAG, "Failed to apply system tweaks", e)
            }
        }
    }
    
    private fun applySavedConfigurations() {
        applicationScope.launch(Dispatchers.IO) {
            try {
                Log.i(TAG, "Applying saved configurations...")
                
                val prefs = PreferenceUtils.getPreferences(this@MaxregnerOSApplication)
                
                // Apply performance settings
                if (prefs.getBoolean("performance_mode_enabled", true)) {
                    SystemUtils.enablePerformanceMode()
                }
                
                // Apply theme settings
                val selectedTheme = prefs.getString("selected_theme", "default")
                SystemUtils.applyTheme(selectedTheme ?: "default")
                
                // Apply custom tweaks
                if (prefs.getBoolean("custom_tweaks_enabled", false)) {
                    SystemUtils.applyCustomTweaks()
                }
                
                Log.i(TAG, "Saved configurations applied successfully")
                
            } catch (Exception e) {
                Log.e(TAG, "Failed to apply saved configurations", e)
            }
        }
    }
    
    fun getVersionInfo(): String {
        return "maxregnerOS ${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})"
    }
    
    fun isMaxregnerOSInstalled(): Boolean {
        return ::core.isInitialized && core.isMaxregnerOSInstalled()
    }
    
    fun getInstallationStatus(): String {
        return if (isMaxregnerOSInstalled()) {
            "Installed and Active"
        } else {
            "Not Installed"
        }
    }
    
    override fun onTerminate() {
        super.onTerminate()
        Log.i(TAG, "maxregnerOS Application terminating...")
        
        if (::core.isInitialized) {
            core.cleanup()
        }
    }
    
    override fun onLowMemory() {
        super.onLowMemory()
        Log.w(TAG, "Low memory warning - cleaning up resources")
        
        if (::core.isInitialized) {
            core.onLowMemory()
        }
    }
    
    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        Log.d(TAG, "Trim memory level: $level")
        
        if (::core.isInitialized) {
            core.onTrimMemory(level)
        }
    }
}
