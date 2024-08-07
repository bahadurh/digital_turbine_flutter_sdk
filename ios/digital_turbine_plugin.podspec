#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint digital_turbine_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'digital_turbine_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin for Digital Turbine SDK.'
  s.description      = <<-DESC
A new Flutter plugin for Digital Turbine SDK.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'FairBidSDK', '~> 3.53.0'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end