package com.example.notifime

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val TAG = "MainActivity"
    private val CHANNEL = "com.example.notifime/notifications"
    private var channel: MethodChannel? = null

    private val notificationReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            Log.d(TAG, "Broadcast received!")
            val packageName = intent?.getStringExtra("packageName")
            val appName = intent?.getStringExtra("appName")
            val title = intent?.getStringExtra("title")
            val message = intent?.getStringExtra("message")
            
            Log.d(TAG, "Package: $packageName, App: $appName, Title: $title")
            
            val data = mapOf(
                "packageName" to packageName,
                "appName" to appName,
                "title" to title,
                "message" to message
            )
            channel?.invokeMethod("onNotificationReceived", data)
            Log.d(TAG, "Sent to Flutter via MethodChannel")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "Configuring Flutter Engine")
        
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        channel?.setMethodCallHandler { call, result ->
            if (call.method == "openNotificationSettings") {
                Log.d(TAG, "Opening notification settings")
                openNotificationSettings()
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
        
        val filter = IntentFilter("com.example.notifime.NOTIFICATION_RECEIVED")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(notificationReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(notificationReceiver, filter)
        }
        Log.d(TAG, "BroadcastReceiver registered")
    }

    private fun openNotificationSettings() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        startActivity(intent)
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(notificationReceiver)
            Log.d(TAG, "BroadcastReceiver unregistered")
        } catch (e: Exception) {
            Log.e(TAG, "Error unregistering receiver: ${e.message}")
        }
        super.onDestroy()
    }
}
