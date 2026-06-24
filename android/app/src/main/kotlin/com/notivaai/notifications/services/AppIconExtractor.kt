package com.notivaai.notifications.services

import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.util.Log
import java.io.File
import java.io.FileOutputStream

object AppIconExtractor {
    private const val TAG = "AppIconExtractor"
    private const val ICON_SIZE = 192

    fun extractAndSaveIcon(context: Context, packageName: String): String? {
        try {
            val pm = context.packageManager
            val appIcon = pm.getApplicationIcon(packageName)
            
            val iconsDir = File(context.filesDir, "app_icons")
            if (!iconsDir.exists()) {
                iconsDir.mkdirs()
            }
            
            val iconFileName = "${packageName.replace(".", "_")}.png"
            val iconFile = File(iconsDir, iconFileName)
            
            if (iconFile.exists()) {
                return iconFile.absolutePath
            }
            
            val bitmap = drawableToBitmap(appIcon)
            val outputStream = FileOutputStream(iconFile)
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            outputStream.flush()
            outputStream.close()
            
            Log.d(TAG, "Saved icon for $packageName at ${iconFile.absolutePath}")
            return iconFile.absolutePath
        } catch (e: Exception) {
            Log.e(TAG, "Error extracting icon for $packageName: ${e.message}")
            return null
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        val bitmap = Bitmap.createBitmap(ICON_SIZE, ICON_SIZE, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    fun getIconPath(context: Context, packageName: String): String? {
        val iconsDir = File(context.filesDir, "app_icons")
        val iconFileName = "${packageName.replace(".", "_")}.png"
        val iconFile = File(iconsDir, iconFileName)
        
        return if (iconFile.exists()) {
            iconFile.absolutePath
        } else {
            extractAndSaveIcon(context, packageName)
        }
    }
}
