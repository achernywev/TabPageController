Pod::Spec.new do |s|
  s.name             = 'TabPageController'
  s.version          = '0.1.0'
  s.summary          = 'Container controller for managing top navigation pages'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }

  s.description      = <<-DESC
  This CocoaPod provides the ability to use TabPageController as a container for multiple UIViewControllers.
                       DESC

  s.homepage         = 'https://github.com/AChernywev/TabPageController'
  s.author           = { 'Aleksandr Chernyshev' => 'achernywev@gmail.com' }
  s.source           = { :git => 'https://github.com/achernywev/TabPageController.git', :tag => s.version.to_s }
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform              = :ios
  s.ios.deployment_target = '12.0'
  s.requires_arc          = true

  s.source_files     = 'Classes/**/*.{swift}'
  s.resources        = 'Resources/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}'
  
  s.frameworks       = "UIKit", "Foundation"
  s.swift_version    = "5.0"
end
