package com.notivaai.notifications.services

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class NotificationListener : NotificationListenerService() {
    private val TAG = "NotificationListener"
    private lateinit var dbHelper: NotificationDatabaseHelper

    companion object {
        var staticChannel: MethodChannel? = null
    }

    override fun onCreate() {
        super.onCreate()
        dbHelper = NotificationDatabaseHelper(applicationContext)
        Log.d(TAG, "NotificationListener service created with database")
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d(TAG, "Notification Listener Connected!")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)

        if (sbn == null) {
            Log.d(TAG, "Received null notification")
            return
        }

        val packageName = sbn.packageName
        if (packageName == "com.notivaai.notifications") {
            return
        }

        Log.d(TAG, "Notification from: $packageName")

        val extras = sbn.notification.extras
        val title = extras.getCharSequence("android.title")?.toString() ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""
        val bigText = extras.getCharSequence("android.bigText")?.toString()
        val message = bigText ?: text

        Log.d(TAG, "Title: $title, Text: $text, BigText: ${bigText ?: "null"}")

        val iconPath = AppIconExtractor.getIconPath(this, packageName)

        val data = mapOf(
            "packageName" to packageName,
            "appName" to getAppName(packageName),
            "title" to title,
            "message" to message,
            "iconPath" to iconPath
        )

        // Try sending to Flutter first (if app is open)
        val channel = staticChannel
        var sentToFlutter = false
        
        if (channel != null) {
            try {
                channel.invokeMethod("onNotificationReceived", data)
                Log.d(TAG, "Sent to Flutter: ${getAppName(packageName)}")
                sentToFlutter = true
            } catch (e: Exception) {
                Log.e(TAG, "Failed to send to Flutter: ${e.message}")
            }
        }
        
        // Always save to database directly (works even if app is closed)
        if (!sentToFlutter) {
            Log.d(TAG, "Flutter unavailable, saving directly to database")
        }
        
        val saved = dbHelper.saveNotification(
            packageName = packageName,
            appName = getAppName(packageName),
            title = title,
            message = message,
            iconPath = iconPath
        )
        
        if (saved) {
            Log.d(TAG, "✓ Notification saved to database: ${getAppName(packageName)}")
        } else {
            Log.e(TAG, "✗ Failed to save notification to database")
        }
    }

    private fun getAppName(packageName: String): String {
        return try {
            val pm = packageManager
            val ai = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(ai).toString()
        } catch (e: Exception) {
            Log.e(TAG, "Error getting app name: ${e.message}")
            packageName
        }
    }
}
