#!/bin/bash

echo "======================================"
echo "Complete Firebase Fix for iOS"
echo "======================================"
echo ""

# Navigate to project root
cd /Users/apple/StudioProjects/IJS-Vault-Flutter-App

echo "Step 1: Installing/updating FlutterFire CLI..."
dart pub global activate flutterfire_cli

echo ""
echo "Step 2: Flutter clean..."
flutter clean

echo ""
echo "Step 3: Getting Flutter dependencies..."
flutter pub get

echo ""
echo "Step 4: Generating firebase_options.dart..."
# Use the existing Firebase config files
flutterfire configure --yes --platforms=ios,android

echo ""
echo "Step 5: Cleaning iOS pods..."
cd ios
rm -rf Pods Podfile.lock .symlinks/

echo ""
echo "Step 6: Updating CocoaPods repository..."
pod repo update

echo ""
echo "Step 7: Installing CocoaPods dependencies..."
pod install

echo ""
echo "======================================"
echo "✅ Complete! Firebase is now configured."
echo "======================================"
echo ""
echo "Next: Update your main.dart to import firebase_options.dart"
echo "Then run: flutter run"

