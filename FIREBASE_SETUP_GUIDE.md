# Firebase Authentication Setup Guide

## 🚨 IMPORTANT: Enable Authentication Methods in Firebase Console

You're getting authentication errors because the authentication methods are not enabled in your Firebase project. Follow these steps:

### 1. **Go to Firebase Console**
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project: **cinec-movie-app**

### 2. **Enable Authentication**
1. In the left sidebar, click **"Authentication"**
2. If you see "Get started", click it
3. Go to the **"Sign-in method"** tab

### 3. **Enable Required Sign-in Methods**

#### ✅ **Email/Password Authentication**
1. Click on **"Email/Password"**
2. Enable the **first toggle** (Email/Password)
3. Click **"Save"**

#### ✅ **Google Authentication**
1. Click on **"Google"**
2. **Enable** the toggle
3. Add your **support email** (your Gmail address)
4. Click **"Save"**

#### ✅ **Apple Authentication** (Optional)
1. Click on **"Apple"**
2. **Enable** the toggle if you want Apple Sign-In
3. Configure the required settings
4. Click **"Save"**

### 4. **Set up Firestore Database**
1. In the left sidebar, click **"Firestore Database"**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select a location (choose closest to you)
5. Click **"Done"**

### 5. **Configure Firestore Security Rules**
Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admins can read all user data
    match /users/{userId} {
      allow read: if request.auth != null && 
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### 6. **Test the Application**

After enabling these authentication methods, your app should work properly. The error you were getting indicates that:

- ❌ Email/Password authentication was **disabled**
- ❌ Google authentication was **disabled**
- ❌ Firestore was not set up

## 🔍 **Common Issues & Solutions**

### **Error: "operation-not-allowed"**
- **Solution**: Enable Email/Password authentication in Firebase Console

### **Error: "api-key-not-valid"**
- **Solution**: Regenerate Firebase configuration with `flutterfire configure`

### **Error: "app-not-authorized"**
- **Solution**: Make sure your domain is authorized in Firebase settings

### **Error: "network-request-failed"**
- **Solution**: Check internet connection and Firebase project status

## 🚀 **After Setup**

1. **Test Email Registration**: Try creating a new account
2. **Test Google Sign-In**: Try signing in with Google
3. **Check Firestore**: Verify user documents are being created
4. **Test Admin Creation**: Try creating admin account with secret key

## 📱 **Platform-Specific Notes**

- **Web**: Fully supported with all authentication methods
- **Android**: Requires google-services.json (already configured)
- **iOS**: Requires GoogleService-Info.plist and Apple Developer setup
- **Desktop**: Uses web authentication methods

---

**✅ Complete these steps and your authentication will work perfectly!**
