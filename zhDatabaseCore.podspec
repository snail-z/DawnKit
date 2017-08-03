#
# Be sure to run `pod lib lint zhDatabaseCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'zhDatabaseCore'
  s.version          = '0.1.1'
  s.summary          = 'Based on FMDB package, the use of more simple and easy.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.homepage         = 'https://github.com/snail-z/zhDatabaseCore'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhanghao' => 'haozhang0770@163.com' }
  s.source           = { :git => 'https://github.com/snail-z/zhDatabaseCore.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'zhDatabaseCore/Classes/**/*'
  
  # s.resource_bundles = {
  #   'zhDatabaseCore' => ['zhDatabaseCore/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency "FMDB", "~> 2.6.2"

end
