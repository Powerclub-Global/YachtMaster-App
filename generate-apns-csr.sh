#!/bin/bash

echo "🔐 Generating APNs Certificate Signing Request"
echo "=============================================="
echo ""

# Generate private key and CSR
openssl req -new -newkey rsa:2048 -nodes \
  -keyout YachtMaster_APNs_Private_Key.key \
  -out YachtMaster_APNs_CSR.certSigningRequest \
  -subj "/emailAddress=support@yachtmasterapp.com/CN=YachtMaster APNs/C=US"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ CSR Generated Successfully!"
    echo ""
    echo "Files created:"
    echo "  - YachtMaster_APNs_CSR.certSigningRequest (upload to Apple)"
    echo "  - YachtMaster_APNs_Private_Key.key (keep secure!)"
    echo ""
    echo "Next steps:"
    echo "1. Go to: https://developer.apple.com/account/resources/certificates/list"
    echo "2. Click '+' to create a new certificate"
    echo "3. Choose 'Apple Push Notification service SSL (Sandbox & Production)'"
    echo "4. Upload YachtMaster_APNs_CSR.certSigningRequest"
    echo "5. Download the certificate (.cer file)"
    echo "6. Convert to .p12: openssl x509 -in aps.cer -inform der -out YachtMaster_APNs.pem"
    echo "7. Upload .p12 to Firebase Console"
else
    echo "❌ Failed to generate CSR"
    exit 1
fi
