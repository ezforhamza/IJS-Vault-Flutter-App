#!/bin/bash

echo "======================================"
echo "Fixing Firebase Version Conflict"
echo "======================================"
echo ""

echo "Step 1: Flutter clean..."
flutter clean

echo ""
echo "Step 2: Removing iOS build artifacts..."
cd ios
rm -rf Pods Podfile.lock
rm -rf .symlinks/
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec

echo ""
echo "Step 3: Returning to project root..."
cd ..

echo ""
echo "Step 4: Getting Flutter dependencies..."
flutter pub get

echo ""
echo "Step 5: Updating CocoaPods specs repository..."
cd ios
pod repo update

echo ""
echo "Step 6: Installing CocoaPods dependencies..."
pod install

echo ""
echo "======================================"
echo "✅ Done! Your iOS pods are now updated."
echo "======================================"
echo ""
echo "You can now run your app with: flutter run"

