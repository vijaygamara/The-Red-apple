package xyz.multipl.multiplapp;

import android.util.Log;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class MultiplNotificationService extends FirebaseMessagingService {

    @Override
    public void onNewToken(String token) {
        super.onNewToken(token);
        Log.d("FCM", "Refreshed token: " + token);
        // Send token to your server here
        // Example: sendTokenToServer(token);
    }

    @Override
    public void onMessageReceived(RemoteMessage message) {
        Log.d("FCM", "From: " + message.getFrom());
        Log.d("FCM", "Message data payload: " + message.getData().toString());

        // Handle the message here
        if (message.getNotification() != null) {
            Log.d("FCM", "Message Notification Body: " + message.getNotification().getBody());
        }
    }
}