#
# Be sure to run `pod lib lint BancardVposConnector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BancardVposConnector'
  s.version          = '0.1.0'
  s.summary          = 'iOS Integration for credit cards and payment management using VPOS.'
  s.description      = <<-DESC
    This library allows commerces to accept payments from customers,
    as well as manage customer cards while remaining fully PCI compliant.
                       DESC
  s.homepage         = 'https://github.com/Mauricio Cousillas/BancardVposConnector' # TODO: Change this
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mauricio Cousillas' => 'mauricio.cousillas@moove-it.com' }
  s.source           = { :git => 'https://github.com/Mauricio Cousillas/BancardVposConnector.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'

  s.source_files = 'BancardVposConnector/Core/**/*'
  
   s.frameworks = 'UIKit', 'WebKit'
end
