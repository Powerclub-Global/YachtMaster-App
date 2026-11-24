#!/bin/bash

echo "🍎 YachtMaster iOS Setup Script"
echo "================================"
echo ""

# Check if running with sudo for initial commands
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  This script needs sudo access for Xcode setup."
    echo "Please run: sudo bash setup-ios.sh"
    exit 1
fi

echo "Step 1: Configuring Xcode..."
xcode-select --switch /Applications/Xcode.app/Contents/Developer
if [ $? -eq 0 ]; then
    echo "✅ Xcode path configured"
else
    echo "❌ Failed to configure Xcode path"
    exit 1
fi

echo ""
echo "Step 2: Running Xcode first launch..."
xcodebuild -runFirstLaunch
if [ $? -eq 0 ]; then
    echo "✅ Xcode first launch completed"
else
    echo "❌ Xcode first launch failed"
    exit 1
fi

echo ""
echo "Step 3: Accepting Xcode license..."
xcodebuild -license accept
if [ $? -eq 0 ]; then
    echo "✅ Xcode license accepted"
else
    echo "❌ Failed to accept Xcode license"
    exit 1
fi

echo ""
echo "Step 4: Installing CocoaPods..."
gem install cocoapods
if [ $? -eq 0 ]; then
    echo "✅ CocoaPods installed"
else
    echo "❌ Failed to install CocoaPods"
    exit 1
fi

echo ""
echo "Step 5: Installing iOS dependencies..."
cd ios
pod install
if [ $? -eq 0 ]; then
    echo "✅ iOS dependencies installed"
else
    echo "❌ Failed to install iOS dependencies"
    exit 1
fi
cd ..

echo ""
echo "✅ iOS setup complete!"
echo ""
echo "To run the app:"
echo "1. Open Simulator: open -a Simulator"
echo "2. Run the app: flutter run -d iPhone"
