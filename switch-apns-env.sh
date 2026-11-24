#!/bin/bash

if [ "$1" == "dev" ]; then
    echo "Switching to development APNs..."
    sed -i '' 's/<string>production<\/string>/<string>development<\/string>/' ios/Runner/Runner.entitlements
    echo "✅ Switched to development"
elif [ "$1" == "prod" ]; then
    echo "Switching to production APNs..."
    sed -i '' 's/<string>development<\/string>/<string>production<\/string>/' ios/Runner/Runner.entitlements
    echo "✅ Switched to production"
else
    echo "Usage: ./switch-apns-env.sh [dev|prod]"
    exit 1
fi
