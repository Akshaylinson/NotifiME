package com.example.notifime.services

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.content.Intent
import android.util.Log

class NotificationListener : NotificationListenerService() {
    private val TAG = "NotificationListener"

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
        Log.d(TAG, "Notification from: $packageName")

        val extras = sbn.notification.extras
        val title = extras.getCharSequence("android.title")?.toString() ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""
        
        Log.d(TAG, "Title: $title, Text: $text")

        // Broadcast to MainActivity
        val intent = Intent("com.example.notifime.NOTIFICATION_RECEIVED")
        intent.putExtra("packageName", packageName)
        intent.putExtra("appName", getAppName(packageName))
        intent.putExtra("title", title)
        intent.putExtra("message", text)
        sendBroadcast(intent)
        
        Log.d(TAG, "Broadcast sent for notification from: ${getAppName(packageName)}")
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
