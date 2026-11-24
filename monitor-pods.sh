#!/bin/bash

echo "📦 CocoaPods Installation Monitor"
echo "================================="
echo ""

START_TIME=$(date +%s)

while true; do
    # Check if pod install is still running
    if ps aux | grep "pod install" | grep -v grep > /dev/null; then
        CURRENT_TIME=$(date +%s)
        ELAPSED=$((CURRENT_TIME - START_TIME))
        SIZE=$(du -sh /Users/bodhi/Documents/GitHub/YachtMaster-App/ios/Pods 2>/dev/null | awk '{print $1}')
        CPU=$(ps aux | grep "pod install" | grep -v grep | awk '{print $10}')
        MEM=$(ps aux | grep "pod install" | grep -v grep | awk '{print $4}')

        echo "[$(date +%H:%M:%S)] ⏱️  Elapsed: ${ELAPSED}s | 📦 Size: $SIZE | CPU: $CPU | Mem: ${MEM}%"
        sleep 15
    else
        echo ""
        echo "✅ POD INSTALL COMPLETED!"
        echo "Final size: $(du -sh /Users/bodhi/Documents/GitHub/YachtMaster-App/ios/Pods 2>/dev/null | awk '{print $1}')"
        break
    fi
done
