#
# Be sure to run `pod lib lint df-pageviewcontroller-ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'df-pageviewcontroller-ios'
  s.version          = '0.1.0'
  s.summary          = '닥프렌즈의 페이지 컨트롤러 커스텀 라이브러리'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
페이지 컨트롤러를 커스텀해서 보다 쉽게 사용이 가능하게 만든 라이브러리
                       DESC

  s.homepage         = 'https://github.com/Docfriends-Dev/df-pageviewcontroller-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Docfriends' => 'apps@docfriends.com' }
  s.source           = { :git => 'https://github.com/Docfriends-Dev/df-pageviewcontroller-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'df-pageviewcontroller-ios/Classes/**/*'
  
  s.swift_version = '4.2'
  
  # s.resource_bundles = {
  #   'df-pageviewcontroller-ios' => ['df-pageviewcontroller-ios/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
