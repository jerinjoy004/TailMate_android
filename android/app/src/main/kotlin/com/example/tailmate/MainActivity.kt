package com.example.tailmate

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity()

private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val channel = NotificationChannel(
            "channel_id",
            "Channel Name",
            NotificationManager.IMPORTANCE_HIGH
        )
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }
}
