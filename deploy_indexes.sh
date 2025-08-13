#!/bin/bash

echo "=== FIRESTORE INDEX DEPLOYMENT GUIDE ==="
echo ""
echo "🚨 ISSUE: Firestore queries require composite indexes"
echo "📍 ERROR: [cloud_firestore/failed-precondition] The query requires an index"
echo ""
echo "✅ SOLUTION: Deploy the Firestore indexes"
echo ""
echo "🛠️  Step 1: Deploy indexes to Firebase"
echo "firebase deploy --only firestore:indexes"
echo ""
echo "🛠️  Step 2: Wait for indexes to build (usually 2-5 minutes)"
echo "You can monitor progress in Firebase Console → Firestore → Indexes"
echo ""
echo "🛠️  Step 3: Test the app after indexes are built"
echo ""
echo "=== RUNNING DEPLOYMENT ==="

# Check if logged in
echo "Checking Firebase authentication..."
firebase use 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ Not logged in to Firebase. Please run: firebase login"
    exit 1
fi

echo "✅ Firebase CLI ready"
echo ""

# Deploy indexes
echo "🚀 Deploying Firestore indexes..."
firebase deploy --only firestore:indexes

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Indexes deployed successfully!"
    echo ""
    echo "📋 WHAT WAS DEPLOYED:"
    echo "1. userId + bookingDate index (for user bookings list)"
    echo "2. movieId + bookingDate index (for movie-specific bookings)"
    echo "3. movieId + showDate + showtime + status index (for seat availability)"
    echo "4. role + createdAt index (for user management)"
    echo ""
    echo "⏳ IMPORTANT: Indexes are building in the background"
    echo "   - This usually takes 2-5 minutes"
    echo "   - The app will work once indexes are ready"
    echo "   - Monitor progress: Firebase Console → Firestore → Indexes"
    echo ""
    echo "🎯 After indexes are built, users can:"
    echo "   - View their bookings without errors"
    echo "   - See proper seat availability"
    echo "   - Use all booking features"
else
    echo ""
    echo "❌ Deployment failed. Please check:"
    echo "1. Firebase project is selected: firebase use your-project-id"
    echo "2. You have Firestore permissions"
    echo "3. Internet connection is stable"
    echo ""
    echo "Manual deployment command:"
    echo "firebase deploy --only firestore:indexes"
fi
