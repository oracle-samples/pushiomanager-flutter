# Copyright © 2024, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pushiomanager_flutter.podspec` to validate before publishing.

Pod::Spec.new do |s|
  s.name             = 'pushiomanager_flutter'
  s.version          = '7.0.0'
  s.summary          = 'Flutter Plugin for Responsys Mobile SDK'
  s.description      = 'Flutter Plugin for Responsys Mobile SDK'
  s.homepage         = 'https://github.com/oracle-samples/pushiomanager-flutter'
  s.license          = { :file => '../LICENSE.txt' }
  s.author           = { 'Oracle Corp.' => 'neerhaj.joshi@oracle.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.preserve_paths = 'CX_Mobile_SDK.xcframework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework CX_Mobile_SDK -ObjC' }
  s.vendored_frameworks = 'CX_Mobile_SDK.xcframework','OracleCXLocationSDK.xcframework'
  s.preserve_paths 	  = "CX_Mobile_SDK.xcframework/**/*","OracleCXLocationSDK.xcframework/**/*"
  s.libraries               = 'sqlite3'
  s.frameworks              = 'UserNotifications', 'Foundation', 'UIKit'
  s.ios.frameworks          = 'WebKit'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64','OTHER_LDFLAGS' => '-ObjC' }
end
