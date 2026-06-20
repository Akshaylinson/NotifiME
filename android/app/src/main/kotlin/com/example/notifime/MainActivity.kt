package com.example.notifime

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.notifime/notifications"
    private var channel: MethodChannel? = null

    private val notificationReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val data = mapOf(
                "packageName" to intent?.getStringExtra("packageName"),
                "appName" to intent?.getStringExtra("appName"),
                "title" to intent?.getStringExtra("title"),
                "message" to intent?.getStringExtra("message")
            )
            channel?.invokeMethod("onNotificationReceived", data)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        val filter = IntentFilter("com.example.notifime.NOTIFICATION_RECEIVED")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(notificationReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(notificationReceiver, filter)
        }
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(notificationReceiver)
        } catch (e: Exception) {}
        super.onDestroy()
    }
}
