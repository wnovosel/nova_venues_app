#!/bin/sh
set -e

# Install Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Get dependencies (generates Generated.xcconfig)
cd $CI_PRIMARY_REPOSITORY_PATH
flutter pub get

# Install pods
cd ios
pod install
