#
#  Be sure to run `pod spec lint HTLivePushKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "HTLivePushKit"
  s.version      = "0.1.0"
  s.summary      = "This is a Kit for iOS Live Push"
  s.description  = "This is a Kit for iOS Live Push,you can pod this Kit to push video and audio"

  s.homepage     = "https://github.com/helloted/HTLivePushKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "helloted" => "helloted@live.com" }
  s.social_media_url   = "http://www.helloted.com"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/helloted/HTLivePushKit.git", :tag => "#{s.version}" }
<<<<<<< HEAD
  s.source_files  = "Classes", "Classes/**/*.{h,m}","Classes/RTMP/include/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.public_header_files = "Classes/**/*.h"
=======


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "Classes", "Classes/**/*.{h,m}","Classes/RTMP/include/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

>>>>>>> parent of 60dd337... udpate
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"
  s.frameworks  = "AVFoundation","VideoToolbox","AudioToolbox"
<<<<<<< HEAD
  s.library   = "z"

  # 第三方库
  vendored_libraries = 'Libraries/libcrypto.a','Libraries/librtmp.a','Libraries/libssl.a'
=======
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  s.vendored_libraries = "Frameworks/libcrypto.a","Frameworks/librtmp.a","Frameworks/libssl.a"
>>>>>>> parent of 60dd337... udpate


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

<<<<<<< HEAD
  s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2","LIBRARY_SEARCH_PATHS" => "$(SRCROOT)/Libraries/**" }
=======
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
>>>>>>> parent of 60dd337... udpate
  # s.dependency "JSONKit", "~> 1.4"

end
