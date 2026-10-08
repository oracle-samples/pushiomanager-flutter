Pod::Spec.new do |s|
   	s.version                 = "6.56.6"
   	s.name                    = "PushIOManager"
   	s.summary                 = "Responsys iOS SDK"
   	s.documentation_url       = ""
   	s.homepage                = "https://github.com/pushio/PushIOManager_iOS"
   	s.author                  = "Oracle"
        s.license                 = { :file => '../LICENSE.txt' }
   	s.source                  = { :git => "https://github.com/pushio/PushIOManager_iOS", :tag => s.version.to_s }

   	s.module_name             = "CXMobileSDK"

   	s.ios.deployment_target   = "12.0"
   	s.requires_arc            =  true

   	s.vendored_frameworks 	  = "CXMobileSDK.xcframework"
    s.preserve_paths 	  = "CXMobileSDK.xcframework/**/*"
   	
   	s.libraries               = 'sqlite3'
   	s.frameworks              = 'UserNotifications', 'CoreLocation', 'Foundation', 'UIKit'
   	s.ios.frameworks          = 'WebKit'
end
