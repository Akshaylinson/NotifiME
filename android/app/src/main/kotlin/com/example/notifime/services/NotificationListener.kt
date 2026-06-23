package com.example.notifime.services

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import com.example.notifime.MainActivity

class NotificationListener : NotificationListenerService() {
    private val TAG = "NotificationListener"

    companion object {
        private const val CHANNEL = "com.example.notifime/notifications"
        var methodChannel: MethodChannel? = null
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
        if (packageName == "com.example.notifime") {
            return
        }
        
        Log.d(TAG, "Notification from: $packageName")

        val extras = sbn.notification.extras
        val title = extras.getCharSequence("android.title")?.toString() ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""
        
        Log.d(TAG, "Title: $title, Text: $text")

        val iconPath = AppIconExtractor.getIconPath(this, packageName)
        
        val data = mapOf(
            "packageName" to packageName,
            "appName" to getAppName(packageName),
            "title" to title,
            "message" to text,
            "iconPath" to iconPath
        )

        methodChannel?.invokeMethod("onNotificationReceived", data)
        Log.d(TAG, "Sent to Flutter: ${getAppName(packageName)}")
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
