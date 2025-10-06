#!/bin/bash

# Start Firebase Emulators for Local Development
# This script starts all Firebase emulators for testing

set -e

echo "🔥 Starting Firebase Emulators..."
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found!"
    echo "Install it with: npm install -g firebase-tools"
    exit 1
fi

# Check if logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged in to Firebase"
    echo "Run: firebase login"
    exit 1
fi

# Install functions dependencies if needed
if [ -d "functions/functions" ] && [ ! -d "functions/functions/node_modules" ]; then
    echo "📦 Installing functions dependencies..."
    cd functions/functions
    npm install
    cd ../..
fi

# Start emulators
echo "🚀 Launching emulators..."
echo ""
echo "Emulator UI will be available at: http://localhost:4000"
echo "Firestore Emulator: http://localhost:8080"
echo "Auth Emulator: http://localhost:9099"
echo "Functions Emulator: http://localhost:5001"
echo "Storage Emulator: http://localhost:9199"
echo ""
echo "Press Ctrl+C to stop emulators"
echo ""

# Use the emulator config
firebase emulators:start --config firebase.emulator.json --import=./emulator-data --export-on-exit
