#
# Be sure to run `pod lib lint LSGAVPlayerManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LSGAVPlayerManager'
  s.version          = '0.2.0'
  s.summary          = '通过AVPlayer封装可播放本地音频和URL音频；支持耳机外放，可切换扬声器和听筒'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "通过AVPlayer封装可播放本地音频和URL音频；支持耳机外放，可切换扬声器和听筒"

  s.homepage         = 'https://github.com/lsgmn/LSGAVPlayerManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lsgmn' => '851229468@qq.com' }
  s.source           = { :git => 'https://github.com/lsgmn/LSGAVPlayerManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'LSGAVPlayerManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LSGAVPlayerManager' => ['LSGAVPlayerManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.requires_arc = true

end
