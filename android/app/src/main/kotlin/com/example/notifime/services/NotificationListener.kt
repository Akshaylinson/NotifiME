package com.example.notifime.services

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.content.Intent
import android.util.Log

class NotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        
        if (sbn == null) return

        val extras = sbn.notification.extras
        val title = extras.getCharSequence("android.title")?.toString() ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""
        val packageName = sbn.packageName

        val data = mapOf(
            "packageName" to packageName,
            "appName" to getAppName(packageName),
            "title" to title,
            "message" to text,
            "timestamp" to sbn.postTime
        )

        // Broadcast to MainActivity
        val intent = Intent("com.example.notifime.NOTIFICATION_RECEIVED")
        intent.putExtra("packageName", packageName)
        intent.putExtra("appName", getAppName(packageName))
        intent.putExtra("title", title)
        intent.putExtra("message", text)
        sendBroadcast(intent)
    }

    private fun getAppName(packageName: String): String {
        return try {
            val pm = packageManager
            val ai = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(ai).toString()
        } catch (e: Exception) {
            packageName
        }
    }
}
