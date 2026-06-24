package com.example.notifime.services

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class NotificationListener : NotificationListenerService() {
    private val TAG = "NotificationListener"

    companion object {
        var staticChannel: MethodChannel? = null
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

        val channel = staticChannel
        if (channel != null) {
            try {
                channel.invokeMethod("onNotificationReceived", data)
                Log.d(TAG, "Sent to Flutter: ${getAppName(packageName)}")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to send notification to Flutter: ${e.message}", e)
            }
        } else {
            Log.w(TAG, "MethodChannel is null; notification was not forwarded to Flutter")
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
