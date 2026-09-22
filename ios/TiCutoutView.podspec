Pod::Spec.new do |s|
  s.name         = "TiCutoutView"
  s.version      = "0.3.0"
  s.summary      = "A shape-aware cutout container for Titanium iOS."

  s.description  = <<-DESC
                   A Titanium iOS container with configurable circular and rectangular
                   cutouts, materials, shadows, borders, and native animation.
                   DESC

  s.homepage     = "https://github.com/designbymind/TiCutoutView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "DesignByMind LLC"

  s.platform     = :ios
  s.ios.deployment_target = "26.0"

  s.source       = { :git => "https://github.com/designbymind/TiCutoutView.git", :tag => "iOS-v#{s.version}" }

  s.ios.weak_frameworks = "UIKit", "Foundation"
  s.ios.dependency "TitaniumKit"

  s.public_header_files = "Classes/*.h"
  s.source_files = "Classes/*.{h,m,swift}"
end
