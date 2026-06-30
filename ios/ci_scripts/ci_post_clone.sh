#!/bin/sh
set -e

# Xcode Cloud restores cached DerivedData before this script runs.
# That stale cache is what's breaking module resolution — wipe it first.
rm -rf $HOME/Library/Developer/Xcode/DerivedData
rm -rf /Volumes/workspace/DerivedData

git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

cd $CI_PRIMARY_REPOSITORY_PATH
flutter clean
flutter pub get
flutter precache --ios

cd ios
rm -rf Pods Podfile.lock .symlinks
pod install --repo-update
