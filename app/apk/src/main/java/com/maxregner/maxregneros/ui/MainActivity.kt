package com.maxregner.maxregneros.ui

import android.Manifest
import android.annotation.SuppressLint
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.MenuItem
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.lifecycle.lifecycleScope
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.navigateUp
import androidx.navigation.ui.setupActionBarWithNavController
import androidx.navigation.ui.setupWithNavController
import com.maxregner.maxregneros.MaxregnerOSApplication
import com.maxregner.maxregneros.R
import com.maxregner.maxregneros.core.Config
import com.maxregner.maxregneros.databinding.ActivityMainBinding
import com.maxregner.maxregneros.ui.home.HomeFragment
import com.maxregner.maxregneros.ui.installation.InstallationActivity
import com.maxregner.maxregneros.ui.settings.SettingsActivity
import com.maxregner.maxregneros.ui.theme.ThemeManagerActivity
import com.maxregner.maxregneros.ui.performance.PerformanceTunerActivity
import com.maxregner.maxregneros.utils.RootUtils
import com.maxregner.maxregneros.utils.SystemUtils
import com.maxregner.maxregneros.view.MaxregnerOSDialog
import kotlinx.coroutines.launch

/**
 * maxregnerOS Main Activity
 * Primary entry point for the maxregnerOS application
 */
class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var navController: NavController
    private lateinit var appBarConfiguration: AppBarConfiguration
    
    private val app get() = application as MaxregnerOSApplication
    
    // Permission request launcher
    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        handlePermissionResults(permissions)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Apply maxregnerOS theme
        setTheme(R.style.MaxregnerOSTheme)
        
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupNavigation()
        setupUI()
        checkPermissions()
        checkInstallationStatus()
    }
    
    private fun setupNavigation() {
        setSupportActionBar(binding.toolbar)
        
        val navHostFragment = supportFragmentManager
            .findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        navController = navHostFragment.navController
        
        appBarConfiguration = AppBarConfiguration(
            setOf(
                R.id.navigation_home,
                R.id.navigation_installation,
                R.id.navigation_themes,
                R.id.navigation_performance,
                R.id.navigation_settings
            )
        )
        
        setupActionBarWithNavController(navController, appBarConfiguration)
        binding.bottomNavigation.setupWithNavController(navController)
        
        // Handle navigation item selection
        binding.bottomNavigation.setOnItemSelectedListener { item ->
            when (item.itemId) {
                R.id.navigation_home -> {
                    navController.navigate(R.id.navigation_home)
                    true
                }
                R.id.navigation_installation -> {
                    if (checkRootAccess()) {
                        navController.navigate(R.id.navigation_installation)
                    }
                    true
                }
                R.id.navigation_themes -> {
                    navController.navigate(R.id.navigation_themes)
                    true
                }
                R.id.navigation_performance -> {
                    if (checkRootAccess()) {
                        navController.navigate(R.id.navigation_performance)
                    }
                    true
                }
                R.id.navigation_settings -> {
                    navController.navigate(R.id.navigation_settings)
                    true
                }
                else -> false
            }
        }
    }
    
    private fun setupUI() {
        // Setup toolbar
        binding.toolbar.title = getString(R.string.maxregneros_app_name)
        
        // Setup floating action button
        binding.fab.setOnClickListener {
            showQuickActionsDialog()
        }
        
        // Update UI based on installation status
        updateUIForInstallationStatus()
    }
    
    private fun checkPermissions() {
        val requiredPermissions = mutableListOf<String>()
        
        // Check storage permissions
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) 
            != PackageManager.PERMISSION_GRANTED) {
            requiredPermissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
        }
        
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) 
            != PackageManager.PERMISSION_GRANTED) {
            requiredPermissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
        }
        
        // Request permissions if needed
        if (requiredPermissions.isNotEmpty()) {
            permissionLauncher.launch(requiredPermissions.toTypedArray())
        }
    }
    
    private fun handlePermissionResults(permissions: Map<String, Boolean>) {
        val deniedPermissions = permissions.filterValues { !it }
        
        if (deniedPermissions.isNotEmpty()) {
            MaxregnerOSDialog(this) {
                title(R.string.permissions_required)
                message(R.string.permissions_required_message)
                positiveButton(R.string.grant_permissions) {
                    checkPermissions()
                }
                negativeButton(R.string.continue_anyway) {
                    // Continue with limited functionality
                }
            }.show()
        }
    }
    
    private fun checkInstallationStatus() {
        lifecycleScope.launch {
            try {
                val isInstalled = app.isMaxregnerOSInstalled()
                updateInstallationStatusUI(isInstalled)
                
                if (!isInstalled) {
                    showInstallationPrompt()
                }
            } catch (e: Exception) {
                Toast.makeText(this@MainActivity, 
                    "Error checking installation status: ${e.message}", 
                    Toast.LENGTH_LONG).show()
            }
        }
    }
    
    private fun updateInstallationStatusUI(isInstalled: Boolean) {
        binding.bottomNavigation.menu.findItem(R.id.navigation_installation)?.let { item ->
            if (isInstalled) {
                item.setIcon(R.drawable.ic_check_circle)
                item.title = getString(R.string.installed)
            } else {
                item.setIcon(R.drawable.ic_download)
                item.title = getString(R.string.install)
            }
        }
    }
    
    private fun updateUIForInstallationStatus() {
        val isInstalled = app.isMaxregnerOSInstalled()
        
        // Show/hide certain navigation items based on installation status
        binding.bottomNavigation.menu.findItem(R.id.navigation_performance)?.isVisible = isInstalled
        
        // Update FAB icon
        binding.fab.setImageResource(
            if (isInstalled) R.drawable.ic_tune else R.drawable.ic_download
        )
    }
    
    private fun showInstallationPrompt() {
        MaxregnerOSDialog(this) {
            title(R.string.maxregneros_not_installed)
            message(R.string.maxregneros_installation_prompt)
            positiveButton(R.string.install_now) {
                startInstallation()
            }
            negativeButton(R.string.later) {
                // User chose to install later
            }
            neutralButton(R.string.learn_more) {
                showInstallationInfo()
            }
        }.show()
    }
    
    private fun startInstallation() {
        if (checkRootAccess()) {
            val intent = Intent(this, InstallationActivity::class.java)
            startActivity(intent)
        }
    }
    
    private fun showInstallationInfo() {
        MaxregnerOSDialog(this) {
            title(R.string.about_maxregneros)
            message(R.string.maxregneros_description)
            positiveButton(R.string.install_now) {
                startInstallation()
            }
            negativeButton(R.string.close) {
                // Close dialog
            }
        }.show()
    }
    
    private fun checkRootAccess(): Boolean {
        return if (RootUtils.isRootAvailable()) {
            true
        } else {
            MaxregnerOSDialog(this) {
                title(R.string.root_required)
                message(R.string.root_required_message)
                positiveButton(R.string.ok) {
                    // Close dialog
                }
            }.show()
            false
        }
    }
    
    private fun showQuickActionsDialog() {
        val isInstalled = app.isMaxregnerOSInstalled()
        
        if (isInstalled) {
            showInstalledQuickActions()
        } else {
            showNotInstalledQuickActions()
        }
    }
    
    private fun showInstalledQuickActions() {
        MaxregnerOSDialog(this) {
            title(R.string.quick_actions)
            items(arrayOf(
                getString(R.string.reboot_system),
                getString(R.string.reboot_recovery),
                getString(R.string.reboot_bootloader),
                getString(R.string.apply_tweaks),
                getString(R.string.backup_system),
                getString(R.string.system_info)
            )) { _, which ->
                when (which) {
                    0 -> SystemUtils.rebootSystem()
                    1 -> SystemUtils.rebootRecovery()
                    2 -> SystemUtils.rebootBootloader()
                    3 -> applyTweaks()
                    4 -> backupSystem()
                    5 -> showSystemInfo()
                }
            }
            negativeButton(R.string.cancel) {
                // Close dialog
            }
        }.show()
    }
    
    private fun showNotInstalledQuickActions() {
        MaxregnerOSDialog(this) {
            title(R.string.quick_actions)
            items(arrayOf(
                getString(R.string.install_maxregneros),
                getString(R.string.check_compatibility),
                getString(R.string.system_info)
            )) { _, which ->
                when (which) {
                    0 -> startInstallation()
                    1 -> checkCompatibility()
                    2 -> showSystemInfo()
                }
            }
            negativeButton(R.string.cancel) {
                // Close dialog
            }
        }.show()
    }
    
    private fun applyTweaks() {
        lifecycleScope.launch {
            try {
                SystemUtils.applyAllTweaks()
                Toast.makeText(this@MainActivity, 
                    R.string.tweaks_applied_successfully, 
                    Toast.LENGTH_SHORT).show()
            } catch (e: Exception) {
                Toast.makeText(this@MainActivity, 
                    "Error applying tweaks: ${e.message}", 
                    Toast.LENGTH_LONG).show()
            }
        }
    }
    
    private fun backupSystem() {
        // TODO: Implement system backup functionality
        Toast.makeText(this, "Backup functionality coming soon", Toast.LENGTH_SHORT).show()
    }
    
    private fun showSystemInfo() {
        val intent = Intent(this, SystemInfoActivity::class.java)
        startActivity(intent)
    }
    
    private fun checkCompatibility() {
        lifecycleScope.launch {
            val isCompatible = SystemUtils.checkDeviceCompatibility()
            val message = if (isCompatible) {
                getString(R.string.device_compatible)
            } else {
                getString(R.string.device_not_compatible)
            }
            
            MaxregnerOSDialog(this@MainActivity) {
                title(R.string.compatibility_check)
                message(message)
                positiveButton(R.string.ok) {
                    // Close dialog
                }
            }.show()
        }
    }
    
    override fun onSupportNavigateUp(): Boolean {
        return navController.navigateUp(appBarConfiguration) || super.onSupportNavigateUp()
    }
    
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                onBackPressed()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
    
    override fun onResume() {
        super.onResume()
        updateUIForInstallationStatus()
    }
}
