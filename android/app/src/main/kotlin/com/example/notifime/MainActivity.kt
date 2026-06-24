package com.example.notifime

import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationManagerCompat
import com.example.notifime.services.NotificationListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val TAG = "MainActivity"
    private val CHANNEL = "com.example.notifime/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "Configuring Flutter Engine")

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        NotificationListener.staticChannel = channel

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "openNotificationSettings" -> {
                    Log.d(TAG, "Opening notification settings")
                    openNotificationSettings()
                    result.success(true)
                }
                "isNotificationListenerEnabled" -> {
                    result.success(isNotificationListenerEnabled())
                }
                else -> result.notImplemented()
            }
        }

        Log.d(TAG, "MethodChannel configured")
    }

    private fun openNotificationSettings() {
        val intent = android.content.Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        startActivity(intent)
    }

    private fun isNotificationListenerEnabled(): Boolean {
        return NotificationManagerCompat.getEnabledListenerPackages(this).contains(packageName)
    }

    override fun onDestroy() {
        Log.d(TAG, "MainActivity destroyed")
        super.onDestroy()
    }
}
