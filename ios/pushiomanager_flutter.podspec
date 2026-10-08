# Copyright © 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pushiomanager_flutter.podspec` to validate before publishing.

Pod::Spec.new do |s|
  s.name             = 'pushiomanager_flutter'
  s.version          = '7.1.5'
  s.summary          = 'Flutter Plugin for Responsys Mobile SDK'
  s.description      = 'Integrates the Responsys Mobile SDK with Flutter applications on iOS and Android'
  s.homepage         = 'https://github.com/oracle-samples/pushiomanager-flutter'
  s.license          = { :type => 'UPL-1.0', :file => '../LICENSE.txt' }
  s.author           = { 'Oracle Corp.' => 'neerhaj.joshi@oracle.com' }
  s.source           = { :path => '.' }
  # Keep CocoaPods and Swift Package Manager on the same plugin sources.
  s.source_files = 'pushiomanager_flutter/Sources/pushiomanager_flutter/include/souces/**/*.{h,m}'
  s.public_header_files = 'pushiomanager_flutter/Sources/pushiomanager_flutter/include/souces/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework CXMobileSDK -ObjC' }
  s.vendored_frameworks = 'pushiomanager_flutter/CXMobileSDK.xcframework'
  s.preserve_paths = [
    'pushiomanager_flutter/CXMobileSDK.xcframework/**/*',
  ]
  s.libraries               = 'sqlite3'
  s.frameworks              = 'UserNotifications', 'Foundation', 'UIKit'
  s.ios.frameworks          = 'WebKit'

  # Flutter.framework does not contain a i386 slice.
  #s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64','OTHER_LDFLAGS' => '-ObjC' }
end
