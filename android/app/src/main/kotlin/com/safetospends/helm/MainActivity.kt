package com.safetospends.helm

import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val BACKUP_CHANNEL = "com.safetospends.helm/backup"
        private const val SIGNATURE_CHANNEL = "com.safetospends.helm/signature"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Prevent screenshots and recent-apps preview of the app content.
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE,
        )
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Backup channel (existing)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BACKUP_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "excludeFromBackup" -> {
                    val path = (call.argument<String>("path"))
                    if (path != null) {
                        excludeFromBackup(path)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Signature verification channel (anti-tamper)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SIGNATURE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getApkSignatureHash" -> {
                    result.success(getSignatureHash())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun excludeFromBackup(path: String) {
        val file = File(path)
        if (file.exists()) {
            file.setWritable(true)
            file.setReadable(true)
        }
        // Android 11+ (API 30): use the StorageManager exclusion flag.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            getSystemService(android.content.Context.STORAGE_SERVICE)
                ?.let { it as? android.os.storage.StorageManager }
                ?.let { storageManager ->
                    try {
                        storageManager.setCacheBehaviorGroup(file, false)
                        storageManager.setCacheBehaviorTombstone(file, false)
                    } catch (e: Exception) {
                        android.util.Log.w("Helm", "StorageManager exclusion failed", e)
                    }
                }
        }
        // Block Android M+ (API 23) automated backup for this directory by writing
        // the no-backup marker used by BackupAgent. This is a defense-in-depth
        // measure alongside AndroidManifest allowBackup="false".
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                File(file, ".nomedia").createNewFile()
            } catch (e: Exception) {
                android.util.Log.w("Helm", "Failed to write .nomedia marker", e)
            }
        }
    }

    /**
     * Returns the SHA-256 hex digest of the APK signing certificate.
     * If the APK is re-signed with a different keystore, the hash will change.
     */
    private fun getSignatureHash(): String? {
        return try {
            val pm = packageManager
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                pm.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)
            } else {
                @Suppress("DEPRECATION")
                pm.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
            } ?: return null

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val signatures = packageInfo.signingInfo ?: return null
                val certs = if (signatures.hasMultipleSigners()) {
                    signatures.signingCertificateHistory
                } else {
                    signatures.apkContentsSigners
                } ?: return null
                val digest = MessageDigest.getInstance("SHA-256").digest(certs[0].toByteArray())
                digest.joinToString("") { "%02x".format(it) }
            } else {
                @Suppress("DEPRECATION")
                val sig = packageInfo.signatures?.get(0) ?: return null
                val digest = MessageDigest.getInstance("SHA-256").digest(sig.toByteArray())
                digest.joinToString("") { "%02x".format(it) }
            }
        } catch (e: Exception) {
            android.util.Log.w("Helm", "Signature hash retrieval failed", e)
            null
        }
    }
}
