# 🔔 Direct Push Notification Setup Guide

## Overview
Ab notification system direct FCM (Firebase Cloud Messaging) use karta hai jo students ke phones mein direct push notifications bhejta hai, Firebase mein store nahi karta.

## 🚀 Setup Steps

### 1. FCM Server Key Get Karein
1. **Firebase Console** mein jao: https://console.firebase.google.com
2. **Apna project** select karein
3. **Project Settings** (gear icon) click karein
4. **Cloud Messaging** tab pe jao
5. **Server key** copy karein

### 2. Server Key Update Karein
`lib/utils/direct_notification_service.dart` mein line 10 pe:
```dart
static const String _fcmServerKey = 'YOUR_FCM_SERVER_KEY_HERE';
```
Apne actual server key se replace karein.

### 3. Android Permissions
`android/app/src/main/AndroidManifest.xml` mein ye permissions already add hain:
```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

### 4. iOS Setup (Agar iOS support chahiye)
`ios/Runner/Info.plist` mein add karein:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## 🧪 Testing

### 1. App Run Karein
```bash
flutter run
```

### 2. Student Login Karein
- Student login karein
- FCM token automatically save hoga

### 3. Test Notification
- **Notification Settings** screen pe jao
- **"Test Notification System"** button click karein
- Console mein results check karein

### 4. Attendance Test
- Teacher attendance mark karein
- Student ke phone pe notification aani chahiye

## 📱 How It Works

### 1. Student Login
```dart
// Student login pe FCM token save hota hai
await DirectNotificationService.saveTokenForStudent(studentId, token);
```

### 2. Teacher Attendance Save
```dart
// Attendance save pe direct notifications bhejta hai
await DirectNotificationService.sendBatchAttendanceNotifications(
  attendanceMap: attendanceMap,
  className: selectedClass!['className'],
  date: dateStr,
);
```

### 3. Direct FCM Call
```dart
// FCM API directly call hota hai
await _sendFCMNotification(
  token: token,
  title: title,
  body: body,
  data: data,
);
```

## 🔧 Troubleshooting

### Notification Nahin Aa Rahi
1. **FCM Server Key** check karein
2. **Internet connection** check karein
3. **App permissions** check karein
4. **Console logs** check karein

### FCM Token Issues
1. **Firebase setup** check karein
2. **google-services.json** update karein
3. **App restart** karein

### Server Key Error
1. **Firebase Console** se correct key copy karein
2. **Project ID** match karein
3. **Cloud Messaging** enabled hai ya nahin check karein

## 📊 Features

### ✅ Direct Push Notifications
- Firebase mein store nahi hota
- Direct phone pe notification aati hai
- Real-time delivery

### ✅ Attendance Notifications
- Present/Absent status
- Class name aur date
- Custom message

### ✅ Batch Notifications
- Multiple students ko ek saath
- Individual tracking
- Error handling

### ✅ Token Management
- Automatic token refresh
- Firestore mein token storage
- Student-specific tokens

## 🔒 Security

### FCM Server Key
- **Never commit** to git
- **Environment variable** use karein
- **Firebase Console** se manage karein

### Token Security
- **HTTPS** use hota hai
- **Firebase security rules** follow karein
- **Token validation** built-in hai

## 🚀 Production Deployment

### 1. Environment Variables
```dart
// Use environment variables for server key
static const String _fcmServerKey = String.fromEnvironment('FCM_SERVER_KEY');
```

### 2. Build Commands
```bash
# Development
flutter run --dart-define=FCM_SERVER_KEY=your_dev_key

# Production
flutter build apk --dart-define=FCM_SERVER_KEY=your_prod_key
```

### 3. Firebase Rules
```javascript
// Firestore security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /students/{studentId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📞 Support

Agar koi issue hai to:
1. **Console logs** check karein
2. **FCM Server Key** verify karein
3. **Firebase setup** review karein
4. **Network connectivity** test karein

## 🎉 Success Indicators

✅ **Student login** pe FCM token save hota hai
✅ **Teacher attendance** save pe notification bhejta hai
✅ **Student phone** pe notification aati hai
✅ **No Firebase storage** of notifications
✅ **Real-time delivery** hota hai

