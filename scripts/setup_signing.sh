#!/bin/sh

# Fail early
set -eo pipefail

# Decrypt encrypted .gpg files
gpg --quiet --batch --yes --decrypt --passphrase="$DEPLOY_PASSWORD" --output secrets/AZDHS_ios_distribution.cer secrets/AZDHS_ios_distribution.cer.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$DEPLOY_PASSWORD" --output secrets/AZDHS_Covid_Watch_iOS_App_Store.mobileprovision secrets/AZDHS_Covid_Watch_iOS_App_Store.mobileprovision.gpg

# Copy .mobileprovision files to their location
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp secrets/*.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/

# Add distribution certificate to KeyChain
security create-keychain -p "" build.keychain
security import secrets/AZDHS_ios_distribution.cer -t agg -k ~/Library/Keychains/build.keychain -P "$DEPLOY_PASSWORD" -A
security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain
