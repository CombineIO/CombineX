#! /usr/bin/env bash

set -euxo pipefail

GIT_PATH=$(cd ../../../ && pwd)
echo "git \"${GIT_PATH}\"" >| 'Cartfile'

carthage update --platform ios --use-xcframeworks

xcodebuild \
  -scheme MyApp \
  -project MyApp.xcodeproj \
  -sdk iphonesimulator \
  clean build | xcpretty