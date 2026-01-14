#!/bin/bash

echo "🚀 Building IJS Vault Release APK..."
echo ""

# Build release APK with --no-tree-shake-icons flag
# This is required because the file_icon package uses non-constant IconData
flutter build apk --release --no-tree-shake-icons

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo "📦 APK location: build/app/outputs/flutter-apk/app-release.apk"
else
    echo ""
    echo "❌ Build failed. Check the error messages above."
fi
