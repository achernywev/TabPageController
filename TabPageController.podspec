Pod::Spec.new do |s|
  s.name             = "TabPageController"
  s.version          = "1.0.0"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.summary          = "Container controller for managing top navigation pages"
  s.description      = <<-DESC
  "This CocoaPod provides the ability to use TabPageController as a container for multiple UIViewControllers."
                       DESC

  s.homepage              = "https://github.com/achernywev/TabPageController"
  s.source                = { :git => "https://github.com/achernywev/TabPageController.git", :tag => s.version.to_s }
  s.author                = { "Aleksandr Chernyshev" => "achernywev@gmail.com" }
  s.social_media_url      = "https://www.linkedin.com/in/achernywev"
  s.platform              = :ios
  s.ios.deployment_target = "12.0"
  s.requires_arc          = true

  s.source_files     = "Pod/**/*.{swift}"
  s.frameworks       = "UIKit", "Foundation"
  s.swift_version    = "5.0"
end
