#
# Be sure to run `pod lib lint ABProgressButton.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ABProgressButton"
  s.version          = "0.1.0"
  s.summary          = "ABProgressButton provides functionality for creating custom animation of UIButton during processing some task"
  s.homepage         = "https://github.com/abakhtin/ABProgressButton"
  s.license          = "MIT"
  s.author           = { "Alex Bakhtin" => "ai.bakhtin@gmail.com" }
  s.source           = { :git => "https://github.com/abakhtin/ABProgressButton.git", :tag => "0.1.0" }
  s.platform         = :ios, "7.0"
  s.requires_arc     = true
  s.source_files     = 'ABProgressButton/*'
  s.frameworks       = 'UIKit'
end
