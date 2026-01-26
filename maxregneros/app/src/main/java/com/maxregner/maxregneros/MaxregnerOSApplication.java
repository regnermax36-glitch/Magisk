package com.maxregner.maxregneros;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import com.maxregner.maxregneros.core.MaxregnerOSCore;
import com.maxregner.maxregneros.services.MaxregnerOSService;
import com.maxregner.maxregneros.utils.RootUtils;
import com.maxregner.maxregneros.utils.SystemUtils;

/**
 * maxregnerOS Application Class
 * Initializes the core system and manages application lifecycle
 */
public class MaxregnerOSApplication extends Application {
    
    private static final String TAG = "MaxregnerOSApp";
    private static MaxregnerOSApplication instance;
    private MaxregnerOSCore core;
    
    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        
        Log.i(TAG, "maxregnerOS Application starting...");
        
        // Initialize core system
        initializeCore();
        
        // Start background service
        startMaxregnerOSService();
        
        // Apply system tweaks if root is available
        if (RootUtils.isRootAvailable()) {
            applySystemTweaks();
        }
        
        Log.i(TAG, "maxregnerOS Application initialized successfully");
    }
    
    private void initializeCore() {
        try {
            core = new MaxregnerOSCore(this);
            core.initialize();
            
            // Check if maxregnerOS is installed
            if (core.isMaxregnerOSInstalled()) {
                Log.i(TAG, "maxregnerOS installation detected");
                core.validateInstallation();
            } else {
                Log.w(TAG, "maxregnerOS not installed - running in setup mode");
            }
            
        } catch (Exception e) {
            Log.e(TAG, "Failed to initialize maxregnerOS core", e);
        }
    }
    
    private void startMaxregnerOSService() {
        try {
            Intent serviceIntent = new Intent(this, MaxregnerOSService.class);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent);
            } else {
                startService(serviceIntent);
            }
            Log.i(TAG, "maxregnerOS service started");
        } catch (Exception e) {
            Log.e(TAG, "Failed to start maxregnerOS service", e);
        }
    }
    
    private void applySystemTweaks() {
        new Thread(() -> {
            try {
                Log.i(TAG, "Applying system tweaks...");
                
                // Apply performance tweaks
                SystemUtils.applyPerformanceTweaks();
                
                // Apply UI tweaks
                SystemUtils.applyUITweaks();
                
                // Apply Samsung-specific tweaks
                if (SystemUtils.isSamsungDevice()) {
                    SystemUtils.applySamsungTweaks();
                }
                
                Log.i(TAG, "System tweaks applied successfully");
                
            } catch (Exception e) {
                Log.e(TAG, "Failed to apply system tweaks", e);
            }
        }).start();
    }
    
    public static MaxregnerOSApplication getInstance() {
        return instance;
    }
    
    public MaxregnerOSCore getCore() {
        return core;
    }
    
    public static Context getAppContext() {
        return instance.getApplicationContext();
    }
    
    @Override
    public void onTerminate() {
        super.onTerminate();
        Log.i(TAG, "maxregnerOS Application terminating...");
        
        if (core != null) {
            core.cleanup();
        }
    }
}
