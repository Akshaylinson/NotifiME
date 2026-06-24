package com.notivaai.notifications.services

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.util.Log
import android.content.ContentValues

class NotificationDatabaseHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {
    
    companion object {
        private const val DATABASE_NAME = "notifications.db"
        private const val DATABASE_VERSION = 1
        private const val TAG = "NotificationDB"
        
        private const val TABLE_APPS = "apps"
        private const val TABLE_NOTIFICATIONS = "notifications"
        
        private const val KEY_ID = "id"
        private const val KEY_APP_NAME = "app_name"
        private const val KEY_PACKAGE_NAME = "package_name"
        private const val KEY_ICON_PATH = "icon_path"
        private const val KEY_NOTIFICATION_COUNT = "notification_count"
        
        private const val KEY_APP_ID = "app_id"
        private const val KEY_SENDER = "sender"
        private const val KEY_TITLE = "title"
        private const val KEY_MESSAGE = "message"
        private const val KEY_TIMESTAMP = "timestamp"
        private const val KEY_READ_STATUS = "read_status"
        private const val KEY_PRIORITY = "priority"
    }

    override fun onCreate(db: SQLiteDatabase) {
        val createAppsTable = """
            CREATE TABLE IF NOT EXISTS $TABLE_APPS (
                $KEY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $KEY_APP_NAME TEXT NOT NULL,
                $KEY_PACKAGE_NAME TEXT UNIQUE NOT NULL,
                $KEY_ICON_PATH TEXT,
                $KEY_NOTIFICATION_COUNT INTEGER DEFAULT 0
            )
        """.trimIndent()

        val createNotificationsTable = """
            CREATE TABLE IF NOT EXISTS $TABLE_NOTIFICATIONS (
                $KEY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $KEY_APP_ID INTEGER NOT NULL,
                $KEY_SENDER TEXT,
                $KEY_TITLE TEXT,
                $KEY_MESSAGE TEXT,
                $KEY_TIMESTAMP INTEGER NOT NULL,
                $KEY_READ_STATUS INTEGER DEFAULT 0,
                $KEY_PRIORITY TEXT DEFAULT 'medium',
                FOREIGN KEY($KEY_APP_ID) REFERENCES $TABLE_APPS($KEY_ID) ON DELETE CASCADE
            )
        """.trimIndent()

        db.execSQL(createAppsTable)
        db.execSQL(createNotificationsTable)
        Log.d(TAG, "Database tables created")
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        // Handle future upgrades if needed
    }

    fun saveNotification(
        packageName: String,
        appName: String,
        title: String,
        message: String,
        iconPath: String?
    ): Boolean {
        val db = writableDatabase
        return try {
            db.beginTransaction()
            
            // Get or create app
            var appId = getAppId(db, packageName)
            if (appId == -1L) {
                appId = insertApp(db, appName, packageName, iconPath)
            }
            
            if (appId == -1L) {
                Log.e(TAG, "Failed to get/create app ID")
                return false
            }
            
            // Insert notification
            val notificationValues = ContentValues().apply {
                put(KEY_APP_ID, appId)
                put(KEY_SENDER, title)
                put(KEY_TITLE, title)
                put(KEY_MESSAGE, message)
                put(KEY_TIMESTAMP, System.currentTimeMillis())
                put(KEY_READ_STATUS, 0)
                put(KEY_PRIORITY, detectPriorityIndex(title, message))
            }
            
            val notificationId = db.insert(TABLE_NOTIFICATIONS, null, notificationValues)
            
            if (notificationId != -1L) {
                // Update notification count
                db.execSQL("UPDATE $TABLE_APPS SET $KEY_NOTIFICATION_COUNT = $KEY_NOTIFICATION_COUNT + 1 WHERE $KEY_ID = $appId")
                db.setTransactionSuccessful()
                Log.d(TAG, "Notification saved: $appName")
                true
            } else {
                Log.e(TAG, "Failed to insert notification")
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error saving notification: ${e.message}", e)
            false
        } finally {
            db.endTransaction()
        }
    }

    private fun getAppId(db: SQLiteDatabase, packageName: String): Long {
        val cursor = db.query(
            TABLE_APPS,
            arrayOf(KEY_ID),
            "$KEY_PACKAGE_NAME = ?",
            arrayOf(packageName),
            null, null, null
        )
        
        return cursor.use {
            if (it.moveToFirst()) {
                it.getLong(0)
            } else {
                -1L
            }
        }
    }

    private fun insertApp(db: SQLiteDatabase, appName: String, packageName: String, iconPath: String?): Long {
        val values = ContentValues().apply {
            put(KEY_APP_NAME, appName)
            put(KEY_PACKAGE_NAME, packageName)
            put(KEY_ICON_PATH, iconPath)
            put(KEY_NOTIFICATION_COUNT, 0)
        }
        
        return db.insert(TABLE_APPS, null, values)
    }

    private fun detectPriorityIndex(title: String, message: String): Int {
        val content = "$title $message".lowercase()
        
        // High priority patterns (index 2)
        val highPriorityPatterns = listOf(
            "otp", "verification code", "verify", "code is",
            "bank", "transaction", "payment", "credited", "debited",
            "missed call", "calling",
            "interview", "meeting", "appointment"
        )
        
        for (pattern in highPriorityPatterns) {
            if (content.contains(pattern)) {
                return 2 // NotificationPriority.high
            }
        }
        
        // Low priority patterns (index 0)
        val lowPriorityPatterns = listOf(
            "liked", "reacted", "followed",
            "offer", "sale", "discount", "deal",
            "promotion", "marketing"
        )
        
        for (pattern in lowPriorityPatterns) {
            if (content.contains(pattern)) {
                return 0 // NotificationPriority.low
            }
        }
        
        return 1 // NotificationPriority.medium (default)
    }
}
