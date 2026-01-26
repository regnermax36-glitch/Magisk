package com.maxregner.maxregneros.utils

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.BufferedReader
import java.io.DataOutputStream
import java.io.InputStreamReader
import java.util.concurrent.TimeUnit

/**
 * Root Utilities for maxregnerOS
 * Handles all root-related operations including command execution,
 * root access verification, and system-level modifications
 */
object RootUtils {
    
    private const val TAG = "RootUtils"
    private const val COMMAND_TIMEOUT = 30L // seconds
    
    private var rootAccess: Boolean? = null
    private var suPath: String? = null
    
    /**
     * Check if root access is available
     */
    fun isRootAvailable(): Boolean {
        if (rootAccess != null) {
            return rootAccess!!
        }
        
        return try {
            val process = Runtime.getRuntime().exec("su -c 'id'")
            val result = process.waitFor(5, TimeUnit.SECONDS)
            
            if (result && process.exitValue() == 0) {
                val reader = BufferedReader(InputStreamReader(process.inputStream))
                val output = reader.readLine()
                reader.close()
                
                val hasRoot = output?.contains("uid=0") == true
                rootAccess = hasRoot
                
                if (hasRoot) {
                    Log.i(TAG, "Root access confirmed")
                    findSuPath()
                } else {
                    Log.w(TAG, "Root access denied")
                }
                
                hasRoot
            } else {
                Log.w(TAG, "Root check timed out or failed")
                rootAccess = false
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking root access", e)
            rootAccess = false
            false
        }
    }
    
    /**
     * Find the path to the su binary
     */
    private fun findSuPath() {
        val possiblePaths = listOf(
            "/system/bin/su",
            "/system/xbin/su", 
            "/su/bin/su",
            "/sbin/su",
            "/vendor/bin/su",
            "/data/local/tmp/su",
            "/data/local/bin/su"
        )
        
        for (path in possiblePaths) {
            try {
                val process = Runtime.getRuntime().exec("test -x $path")
                if (process.waitFor(2, TimeUnit.SECONDS) && process.exitValue() == 0) {
                    suPath = path
                    Log.d(TAG, "Found su binary at: $path")
                    break
                }
            } catch (e: Exception) {
                // Continue checking other paths
            }
        }
        
        if (suPath == null) {
            suPath = "su" // Fallback to PATH
            Log.d(TAG, "Using su from PATH")
        }
    }
    
    /**
     * Execute a command with root privileges
     */
    suspend fun executeCommand(command: String): String? = withContext(Dispatchers.IO) {
        return@withContext executeCommandSync(command)
    }
    
    /**
     * Execute a command with root privileges synchronously
     */
    fun executeCommandSync(command: String): String? {
        if (!isRootAvailable()) {
            Log.w(TAG, "Root access not available for command: $command")
            return null
        }
        
        var process: Process? = null
        var dataOutputStream: DataOutputStream? = null
        var bufferedReader: BufferedReader? = null
        
        try {
            Log.d(TAG, "Executing root command: $command")
            
            process = Runtime.getRuntime().exec(suPath ?: "su")
            dataOutputStream = DataOutputStream(process.outputStream)
            bufferedReader = BufferedReader(InputStreamReader(process.inputStream))
            
            // Send command
            dataOutputStream.writeBytes("$command\n")
            dataOutputStream.writeBytes("exit\n")
            dataOutputStream.flush()
            
            // Wait for completion with timeout
            val completed = process.waitFor(COMMAND_TIMEOUT, TimeUnit.SECONDS)
            
            if (!completed) {
                Log.w(TAG, "Command timed out: $command")
                process.destroyForcibly()
                return null
            }
            
            // Read output
            val output = StringBuilder()
            var line: String?
            while (bufferedReader.readLine().also { line = it } != null) {
                output.append(line).append("\n")
            }
            
            val exitCode = process.exitValue()
            val result = output.toString().trim()
            
            if (exitCode == 0) {
                Log.d(TAG, "Command executed successfully: $command")
                return result.ifEmpty { null }
            } else {
                Log.w(TAG, "Command failed with exit code $exitCode: $command")
                return null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error executing command: $command", e)
            return null
        } finally {
            try {
                dataOutputStream?.close()
                bufferedReader?.close()
                process?.destroy()
            } catch (e: Exception) {
                Log.e(TAG, "Error closing resources", e)
            }
        }
    }
    
    /**
     * Execute multiple commands in a single root session
     */
    suspend fun executeCommands(commands: List<String>): Map<String, String?> = withContext(Dispatchers.IO) {
        val results = mutableMapOf<String, String?>()
        
        if (!isRootAvailable()) {
            Log.w(TAG, "Root access not available for batch commands")
            return@withContext results
        }
        
        var process: Process? = null
        var dataOutputStream: DataOutputStream? = null
        var bufferedReader: BufferedReader? = null
        
        try {
            Log.d(TAG, "Executing ${commands.size} root commands in batch")
            
            process = Runtime.getRuntime().exec(suPath ?: "su")
            dataOutputStream = DataOutputStream(process.outputStream)
            bufferedReader = BufferedReader(InputStreamReader(process.inputStream))
            
            // Send all commands
            for (command in commands) {
                dataOutputStream.writeBytes("echo \"COMMAND_START:$command\"\n")
                dataOutputStream.writeBytes("$command\n")
                dataOutputStream.writeBytes("echo \"COMMAND_END:$command:\$?\"\n")
            }
            dataOutputStream.writeBytes("exit\n")
            dataOutputStream.flush()
            
            // Wait for completion
            val completed = process.waitFor(COMMAND_TIMEOUT * commands.size, TimeUnit.SECONDS)
            
            if (!completed) {
                Log.w(TAG, "Batch commands timed out")
                process.destroyForcibly()
                return@withContext results
            }
            
            // Parse output
            var currentCommand: String? = null
            val currentOutput = StringBuilder()
            
            var line: String?
            while (bufferedReader.readLine().also { line = it } != null) {
                when {
                    line!!.startsWith("COMMAND_START:") -> {
                        currentCommand = line.substringAfter("COMMAND_START:")
                        currentOutput.clear()
                    }
                    line.startsWith("COMMAND_END:") -> {
                        if (currentCommand != null) {
                            results[currentCommand] = currentOutput.toString().trim().ifEmpty { null }
                        }
                        currentCommand = null
                    }
                    currentCommand != null -> {
                        currentOutput.append(line).append("\n")
                    }
                }
            }
            
            Log.d(TAG, "Batch commands completed successfully")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error executing batch commands", e)
        } finally {
            try {
                dataOutputStream?.close()
                bufferedReader?.close()
                process?.destroy()
            } catch (e: Exception) {
                Log.e(TAG, "Error closing batch resources", e)
            }
        }
        
        return@withContext results
    }
    
    /**
     * Check if a file exists with root access
     */
    suspend fun fileExists(path: String): Boolean = withContext(Dispatchers.IO) {
        val result = executeCommandSync("test -f '$path' && echo 'exists'")
        return@withContext result == "exists"
    }
    
    /**
     * Check if a directory exists with root access
     */
    suspend fun directoryExists(path: String): Boolean = withContext(Dispatchers.IO) {
        val result = executeCommandSync("test -d '$path' && echo 'exists'")
        return@withContext result == "exists"
    }
    
    /**
     * Create a directory with root access
     */
    suspend fun createDirectory(path: String, permissions: String = "755"): Boolean = withContext(Dispatchers.IO) {
        val result = executeCommandSync("mkdir -p '$path' && chmod $permissions '$path'")
        return@withContext result != null
    }
    
    /**
     * Copy a file with root access
     */
    suspend fun copyFile(source: String, destination: String, permissions: String? = null): Boolean = withContext(Dispatchers.IO) {
        val commands = mutableListOf("cp '$source' '$destination'")
        if (permissions != null) {
            commands.add("chmod $permissions '$destination'")
        }
        
        val results = executeCommands(commands)
        return@withContext results.values.all { it != null }
    }
    
    /**
     * Move a file with root access
     */
    suspend fun moveFile(source: String, destination: String): Boolean = withContext(Dispatchers.IO) {
        val result = executeCommandSync("mv '$source' '$destination'")
        return@withContext result != null
    }
    
    /**
     * Delete a file or directory with root access
     */
    suspend fun delete(path: String): Boolean = withContext(Dispatchers.IO) {
        val result = executeCommandSync("rm -rf '$path'")
        return@withContext result != null
    }
    
    /**
     * Set file permissions with root access
     */
    suspend fun setPermissions(path: String, permissions: String): Boolean = withContext(Dispatchers.IO) {
        val result = executeCommandSync("chmod $permissions '$path'")
        return@withContext result != null
    }
    
    /**
     * Set file owner with root access
     */
    suspend fun setOwner(path: String, owner: String, group: String? = null): Boolean = withContext(Dispatchers.IO) {
        val ownerGroup = if (group != null) "$owner:$group" else owner
        val result = executeCommandSync("chown $ownerGroup '$path'")
        return@withContext result != null
    }
    
    /**
     * Mount a filesystem with root access
     */
    suspend fun mount(device: String, mountPoint: String, filesystem: String = "", options: String = ""): Boolean = withContext(Dispatchers.IO) {
        val fsType = if (filesystem.isNotEmpty()) "-t $filesystem" else ""
        val mountOptions = if (options.isNotEmpty()) "-o $options" else ""
        val result = executeCommandSync("mount $fsType $mountOptions '$device' '$mountPoint'")
        return@withContext result != null
    }
    
    /**
     * Unmount a filesystem with root access
     */
    suspend fun unmount(mountPoint: String): Boolean = withContext(Dispatchers.IO) {
        val result = executeCommandSync("umount '$mountPoint'")
        return@withContext result != null
    }
    
    /**
     * Remount a filesystem with different options
     */
    suspend fun remount(mountPoint: String, options: String): Boolean = withContext(Dispatchers.IO) {
        val result = executeCommandSync("mount -o remount,$options '$mountPoint'")
        return@withContext result != null
    }
    
    /**
     * Get system property with root access
     */
    suspend fun getSystemProperty(property: String): String? = withContext(Dispatchers.IO) {
        return@withContext executeCommandSync("getprop '$property'")
    }
    
    /**
     * Set system property with root access
     */
    suspend fun setSystemProperty(property: String, value: String): Boolean = withContext(Dispatchers.IO) {
        val result = executeCommandSync("setprop '$property' '$value'")
        return@withContext result != null
    }
    
    /**
     * Reboot the system
     */
    suspend fun reboot(mode: String = ""): Boolean = withContext(Dispatchers.IO) {
        val rebootCommand = if (mode.isNotEmpty()) "reboot $mode" else "reboot"
        val result = executeCommandSync(rebootCommand)
        return@withContext result != null
    }
    
    /**
     * Check if SELinux is enforcing
     */
    suspend fun isSELinuxEnforcing(): Boolean = withContext(Dispatchers.IO) {
        val result = executeCommandSync("getenforce")
        return@withContext result?.lowercase() == "enforcing"
    }
    
    /**
     * Set SELinux mode
     */
    suspend fun setSELinuxMode(enforcing: Boolean): Boolean = withContext(Dispatchers.IO) {
        val mode = if (enforcing) "1" else "0"
        val result = executeCommandSync("setenforce $mode")
        return@withContext result != null
    }
    
    /**
     * Get the current root method (su, magisk, etc.)
     */
    fun getRootMethod(): String {
        return when {
            executeCommandSync("which magisk") != null -> "Magisk"
            executeCommandSync("which supersu") != null -> "SuperSU"
            executeCommandSync("test -f /system/xbin/su") != null -> "System SU"
            else -> "Unknown"
        }
    }
    
    /**
     * Clear the root access cache (force recheck)
     */
    fun clearRootCache() {
        rootAccess = null
        suPath = null
        Log.d(TAG, "Root access cache cleared")
    }
}
