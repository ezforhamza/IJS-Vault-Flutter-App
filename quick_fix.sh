#!/bin/bash

echo "🔄 Updating CocoaPods specs repository..."
echo "This may take a few minutes..."
pod repo update

echo ""
echo "🔧 Installing CocoaPods dependencies..."
cd ios
pod install

cd ..

echo ""
echo "✅ Done! Now try: flutter run"

