# Notification System Setup Guide

This guide explains how to set up and use the notification system for The Red Apple app.

## Features Added

### 1. Attendance Notifications
- When teachers complete attendance, students receive automatic notifications
- Notifications include class name, date, and attendance status
- Students can view attendance updates in real-time

### 2. Teacher Notes System
- Teachers can write and send notes to specific classes
- Notes include title, content, and date
- Students receive notifications when new notes are posted
- Teachers can view, edit, and manage all their notes

### 3. Student Notification Center
- Students can view all notifications in a dedicated screen
- Notifications are categorized by type (attendance, notes, etc.)
- Read/unread status tracking
- Mark all notifications as read functionality

## Setup Instructions

### 1. Firebase Cloud Messaging (FCM) Setup

#### Get FCM Server Key
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings (gear icon)
4. Go to Cloud Messaging tab
5. Copy the Server key

#### Update Notification Service
1. Open `lib/utils/notification_service.dart`
2. Replace `YOUR_FCM_SERVER_KEY` with your actual FCM server key:

```dart
static const String _serverKey = 'your_actual_fcm_server_key_here';
```

### 2. Firebase Security Rules

Add these rules to your Firestore security rules:

```javascript
// Allow notifications collection
match /notifications/{document} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}

// Allow notes collection
match /notes/{document} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```

### 3. Android Configuration

#### Update android/app/build.gradle
Add these permissions to your AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

### 4. iOS Configuration

#### Update ios/Runner/Info.plist
Add these keys:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## How to Use

### For Teachers

#### Writing Notes
1. Login to teacher dashboard
2. Click "Write Note" button
3. Select medium and class
4. Enter note title and content
5. Choose date
6. Toggle notification option (enabled by default)
7. Click "Save & Send Note"

#### Viewing Notes
1. Click "View Notes" button
2. Filter by medium and class (optional)
3. View all notes with edit/delete options
4. Click the + button to create new notes

#### Attendance Notifications
- Notifications are automatically sent when attendance is saved
- No additional setup required

### For Students

#### Viewing Notes
1. Login to student dashboard
2. Navigate to "Notes" tab
3. View all notes from teachers
4. Notes are organized by date

#### Viewing Notifications
1. Navigate to "Notifications" tab
2. View all notifications (attendance, notes, etc.)
3. Tap notifications to mark as read
4. Use "Mark all as read" button

## Database Structure

### Notifications Collection
```javascript
{
  type: "attendance" | "note" | "homework" | "result",
  className: "string",
  medium: "string",
  title: "string",
  body: "string",
  data: {
    // Additional data based on type
  },
  timestamp: "timestamp",
  read: "boolean"
}
```

### Notes Collection
```javascript
{
  title: "string",
  content: "string",
  medium: "string",
  class: "string",
  date: "string (YYYY-MM-DD)",
  createdAt: "timestamp"
}
```

## Troubleshooting

### Notifications Not Working
1. Check FCM server key is correct
2. Verify Firebase project configuration
3. Check device internet connection
4. Ensure app has notification permissions

### Notes Not Appearing
1. Check Firestore security rules
2. Verify class and medium match exactly
3. Check Firestore console for errors

### FCM Token Issues
1. Students must login to generate FCM tokens
2. Check if tokens are saved in student documents
3. Verify Firebase Messaging is properly initialized

## Testing

### Test Attendance Notifications
1. Login as teacher
2. Mark attendance for a class
3. Check if students receive notifications
4. Verify notification appears in student app

### Test Notes
1. Login as teacher
2. Write a note for a specific class
3. Check if students receive notifications
4. Verify note appears in student notes screen

## Security Considerations

1. FCM server key should be kept secure
2. Consider implementing user authentication
3. Validate input data before saving
4. Implement rate limiting for notifications
5. Monitor FCM usage to avoid quota limits

## Performance Tips

1. Batch notifications when possible
2. Use Firestore offline persistence
3. Implement pagination for large lists
4. Cache frequently accessed data
5. Optimize notification payload size


