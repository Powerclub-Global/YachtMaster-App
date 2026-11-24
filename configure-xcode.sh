#!/bin/bash

echo "🍎 Xcode Configuration for iOS Development"
echo "=========================================="
echo ""

echo "⚠️  This script requires sudo access."
echo "Please enter your password when prompted."
echo ""

# Configure Xcode path
echo "Step 1: Setting Xcode developer directory..."
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

if [ $? -eq 0 ]; then
    echo "✅ Xcode path configured"
else
    echo "❌ Failed to configure Xcode"
    exit 1
fi

# Accept license
echo ""
echo "Step 2: Accepting Xcode license..."
sudo xcodebuild -license accept

if [ $? -eq 0 ]; then
    echo "✅ License accepted"
else
    echo "❌ Failed to accept license"
    exit 1
fi

# Run first launch
echo ""
echo "Step 3: Running Xcode first launch setup..."
sudo xcodebuild -runFirstLaunch

if [ $? -eq 0 ]; then
    echo "✅ Xcode setup complete"
else
    echo "❌ Xcode setup failed"
    exit 1
fi

echo ""
echo "✅ Xcode is now configured for iOS development!"
echo ""
echo "To verify, run: flutter doctor"
