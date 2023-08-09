#
# Be sure to run `pod lib lint DawnKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DawnKit'
  s.version          = '1.0.2'
  s.summary          = 'Daily accumulation of DawnKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/snail-z/DawnKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhanghao' => 'haozhang0770@163.com' }
  s.source           = { :git => 'https://github.com/snail-z/DawnKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.1'

  s.source_files = 'DawnKit/Classes/**/*'
  
  s.subspec 'DawnExtensions' do |ss|
      ss.source_files = 'DawnKit/Classes/DawnExtensions/**/*'
  end
  
  s.subspec 'DawnUI' do |ss|
      ss.dependency 'DawnKit/DawnExtensions'
      ss.source_files = 'DawnKit/Classes/DawnUI/**/*'
  end
  
  # s.resource_bundles = {
  #   'DawnKit' => ['DawnKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
