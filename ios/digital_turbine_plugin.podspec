#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint digital_turbine_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'digital_turbine_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A flutter plugin for Digital Turbine SDK integration'
  s.description      = <<-DESC
A flutter plugin for Digital Turbine SDK integration
                       DESC
  s.homepage         = 'http://gaya.app'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Gaya Communities ltd' => 'bahadur@gaya.app' }
  s.source           = { :path => '.' }
#   s.source_files  = 'Classes/**/*.{swift}'
    s.source_files     = 'Classes/**/*.{h,m, swift}'

  s.dependency 'Flutter'
  s.platform = :ios, '11.0'


  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.dependency 'FairBidSDK', '~> 3.53.0'
end
