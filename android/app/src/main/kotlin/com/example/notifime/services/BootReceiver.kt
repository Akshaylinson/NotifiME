package com.example.notifime.services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    private val TAG = "BootReceiver"
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d(TAG, "Device boot completed - NotificationListener will auto-start")
            // NotificationListenerService auto-starts if permission is granted
            // No explicit start needed, just log for confirmation
        }
    }
}
