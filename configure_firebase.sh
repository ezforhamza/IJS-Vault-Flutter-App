#!/bin/bash

echo "======================================"
echo "Configuring Firebase for Flutter"
echo "======================================"
echo ""

echo "Step 1: Installing/updating FlutterFire CLI..."
dart pub global activate flutterfire_cli

echo ""
echo "Step 2: Generating firebase_options.dart..."
echo "This will use your existing Firebase configuration files."
echo ""

# Run flutterfire configure in non-interactive mode if possible
# This will detect google-services.json and GoogleService-Info.plist
flutterfire configure --yes

echo ""
echo "======================================"
echo "✅ Firebase configuration complete!"
echo "======================================"
echo ""
echo "The firebase_options.dart file has been generated."
echo "You can now run your app."

