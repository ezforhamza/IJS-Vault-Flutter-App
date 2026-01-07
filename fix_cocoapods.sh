#!/bin/bash

echo "Fixing CocoaPods Firebase version conflict..."
echo "Navigating to iOS directory..."
cd ios

echo "Cleaning up old pods..."
rm -rf Pods Podfile.lock

echo "Updating CocoaPods repository..."
pod repo update

echo "Installing pods with updated dependencies..."
pod install

echo "Done! You can now try running your app again."

