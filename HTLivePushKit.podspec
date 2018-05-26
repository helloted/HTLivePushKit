#
#  Be sure to run `pod spec lint HTLivePushKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "HTLivePushKit"
  s.version      = "1.0.8"
  s.summary      = "This is a Kit for iOS Live Push"
  s.description  = "This is a Kit for iOS Live Push,you can pod this Kit to push video and audio"
  s.homepage     = "http://www.helloted.com"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "helloted" => "helloted@live.com" }
  s.social_media_url   = "http://helloted.com"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/helloted/HTLivePushKit.git", :tag => "#{s.version}" }
  s.source_files  = "include/**/*.{h,m}","Classes/**/*.{h,m}"
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/include/**", "LIBRARY_SEARCH_PATHS" => "${PODS_ROOT}/#{s.name}/libs/**" }
  # s.public_header_files = 'Classes/HTLivePushKit.h'
  s.frameworks  = "AVFoundation","VideoToolbox","AudioToolbox"
  s.library   = "z"
  s.vendored_libraries = "Libraries/libcrypto.a","Libraries/librtmp.a","Libraries/libssl.a"
  s.requires_arc = true

  # s.xcconfig = { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/include/**", "LIBRARY_SEARCH_PATHS" => "${PODS_ROOT}/#{s.name}/lib/**" }
  # s.dependency "JSONKit", "~> 1.4"

  s.subspec 'HTCapture' do |ss|
    ss.public_header_files = 'Classes/Capture/*.h'
    ss.source_files  = "Classes/Capture/*.{h,m}"
  end

  s.subspec 'HTEncoder' do |ss|
    ss.public_header_files = 'Classes/Encoder/*.h'
    ss.source_files  = "Classes/Encoder/*.{h,m}"
  end


  # s.subspec 'HTRTMP' do |ss|
  #   ss.public_header_files = 'Classes/RTMP/*.h'
  #   ss.source_files  = "include/**/*.{h,m}","Classes/RTMP/*.{h,m}"
  #   # ss.vendored_libraries = "Libraries/libcrypto.a","Libraries/librtmp.a","Libraries/libssl.a"
  # end

end
