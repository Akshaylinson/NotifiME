package com.example.notifime

import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.notifime.services.NotificationListener

class MainActivity: FlutterActivity() {
    private val TAG = "MainActivity"
    private val CHANNEL = "com.example.notifime/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "Configuring Flutter Engine")
        
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        NotificationListener.methodChannel = channel
        
        channel.setMethodCallHandler { call, result ->
            if (call.method == "openNotificationSettings") {
                Log.d(TAG, "Opening notification settings")
                openNotificationSettings()
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
        
        Log.d(TAG, "MethodChannel configured")
    }

    private fun openNotificationSettings() {
        val intent = android.content.Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        startActivity(intent)
    }

    override fun onDestroy() {
        Log.d(TAG, "MainActivity destroyed")
        super.onDestroy()
    }
}
