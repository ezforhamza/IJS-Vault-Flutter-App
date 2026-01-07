#!/bin/bash

echo "======================================"
echo "Final iOS Build Fix"
echo "======================================"
echo ""

cd /Users/apple/StudioProjects/IJS-Vault-Flutter-App

echo "Step 1: Flutter clean..."
flutter clean

echo ""
echo "Step 2: Getting Flutter dependencies..."
flutter pub get

echo ""
echo "Step 3: Cleaning iOS pods..."
cd ios
rm -rf Pods Podfile.lock .symlinks/

echo ""
echo "Step 4: Updating CocoaPods repository..."
echo "This may take a few minutes..."
pod repo update

echo ""
echo "Step 5: Installing CocoaPods dependencies..."
pod install

cd ..

echo ""
echo "======================================"
echo "✅ All fixed!"
echo "======================================"
echo ""
echo "Your app is ready to run. Try:"
echo "flutter run"
echo ""
echo "Or select your device in Xcode and run from there."

