#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint intercom_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'intercom_ios'
  s.version          = '1.0.0'
  s.summary          = 'iOS implementation of the intercom_flutter_plugin.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'https://github.com/chuvakpavel/IntercomeFlutter/tree/main/intercom_ios'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Igniscor' => 'chuvak.pavel@gmail.com' }
  s.source           = { :http => 'https://github.com/chuvakpavel/IntercomeFlutter/tree/main/intercom_ios' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.static_framework = true
  s.dependency 'Intercom', '16.0.1'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
