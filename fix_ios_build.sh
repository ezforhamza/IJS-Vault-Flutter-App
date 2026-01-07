#!/bin/bash

echo "🔄 Updating CocoaPods repository..."
pod repo update

echo "🧹 Cleaning iOS build artifacts..."
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo "🧹 Cleaning Flutter build..."
cd ..
flutter clean

echo "📦 Getting Flutter packages..."
flutter pub get

echo "📦 Upgrading Flutter packages..."
flutter pub upgrade

echo "🔧 Deintegrating old CocoaPods setup..."
cd ios
pod deintegrate

echo "🔧 Installing CocoaPods dependencies..."
pod install --repo-update

cd ..

echo "✅ Done! Now try running your app with: flutter run"
echo ""
echo "If the issue persists, try opening Xcode and cleaning the build folder:"
echo "  1. Open ios/Runner.xcworkspace in Xcode"
echo "  2. Product > Clean Build Folder (Shift+Cmd+K)"
echo "  3. Close Xcode and run: flutter run"

