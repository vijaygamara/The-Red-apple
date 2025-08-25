# Notification System Setup Guide

## Overview
This notification system allows students to receive push notifications when teachers mark their attendance. The system uses Firebase Cloud Messaging (FCM) to send notifications to students' devices.

## Features
- ✅ FCM token management for students
- ✅ Attendance notifications when teachers save attendance
- ✅ Notification settings for students
- ✅ Foreground and background notification handling
- ✅ Notification overlay for in-app notifications

## Setup Instructions

### 1. Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** > **Cloud Messaging**
4. Copy the **Server key** (you'll need this for sending notifications)

### 2. Update FCM Server Key

1. Open `lib/utils/notification_service.dart`
2. Replace `YOUR_FCM_SERVER_KEY_HERE` with your actual FCM server key:

```dart
static const String _serverKey = 'YOUR_ACTUAL_FCM_SERVER_KEY';
```

### 3. Android Configuration

1. Make sure you have the latest `google-services.json` file in `android/app/`
2. Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

3. Add the following inside the `<application>` tag:

```xml
<service
    android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

### 4. iOS Configuration

1. Make sure you have the latest `GoogleService-Info.plist` file in `ios/Runner/`
2. Add the following to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 5. Testing the Notification System

1. **Student Login**: When a student logs in, their FCM token is automatically saved to Firestore
2. **Teacher Marks Attendance**: When a teacher saves attendance, notifications are sent to all students in that class
3. **Student Receives Notification**: Students receive notifications about their attendance status

## How It Works

### 1. Student Login Flow
```dart
// When student logs in
1. Get FCM token from Firebase Messaging
2. Save token to student's document in Firestore
3. Token is used for sending notifications later
```

### 2. Attendance Notification Flow
```dart
// When teacher saves attendance
1. Teacher marks attendance for students
2. System gets FCM tokens for all students in the class
3. Sends individual notifications to each student
4. Students receive notification about their attendance status
```

### 3. Notification Types
- **Attendance**: "You were marked present/absent in [Class] on [Date]"
- **Homework**: "New homework assigned in [Class]"
- **Results**: "New results published for [Class]"
- **Events**: "New school event: [Event Name]"

## Code Structure

### Key Files:
- `lib/utils/notification_service.dart` - Main notification service
- `lib/utils/notification_overlay.dart` - In-app notification display
- `lib/student_dashborad_screen/notification_settings.dart` - Notification preferences
- `lib/student_dashborad_screen/student_login.dart` - FCM token saving
- `lib/Attendance_Screen/attendancescreen.dart` - Attendance notification sending

### Key Methods:
- `NotificationService.initialize()` - Initialize FCM
- `NotificationService.saveTokenForStudent()` - Save FCM token
- `NotificationService.sendAttendanceNotification()` - Send attendance notification
- `NotificationService.sendBatchAttendanceNotifications()` - Send to multiple students

## Troubleshooting

### Common Issues:

1. **Notifications not working**
   - Check FCM server key is correct
   - Verify `google-services.json` is up to date
   - Check device has internet connection

2. **FCM token not saving**
   - Check Firebase permissions
   - Verify student document exists in Firestore
   - Check console logs for errors

3. **Notifications not showing in foreground**
   - Make sure `OverlaySupport` is properly initialized
   - Check notification permissions are granted

### Debug Commands:
```dart
// Check FCM token
String? token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');

// Check notification permissions
NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
print('Permission status: ${settings.authorizationStatus}');
```

## Security Considerations

1. **FCM Server Key**: Keep your FCM server key secure and never commit it to public repositories
2. **Token Validation**: Validate FCM tokens before sending notifications
3. **Rate Limiting**: Implement rate limiting to prevent spam notifications
4. **User Consent**: Always request user permission before sending notifications

## Future Enhancements

- [ ] Notification history
- [ ] Custom notification sounds
- [ ] Notification categories
- [ ] Bulk notification management
- [ ] Notification analytics
- [ ] Push notification scheduling

## Support

If you encounter any issues with the notification system, please check:
1. Firebase Console logs
2. Device logs
3. Network connectivity
4. FCM token validity

For additional help, refer to the [Firebase Cloud Messaging documentation](https://firebase.google.com/docs/cloud-messaging).

