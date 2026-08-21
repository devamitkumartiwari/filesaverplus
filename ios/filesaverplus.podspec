#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint filesaverplus.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'filesaverplus'
  s.version          = '1.0.0'
  s.summary          = 'FileSaverPlus Flutter plugin — iOS support.'
  s.description      = <<-DESC
Flutter plugin for saving files to device storage, presenting the iOS share sheet.
                       DESC
  s.homepage         = 'https://github.com/devamitkumartiwari/filesaverplus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Amit Kumar Tiwari' => 'amtechnovation@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'filesaverplus/Sources/filesaverplus/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '16.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {'filesaverplus_privacy' => ['filesaverplus/Sources/filesaverplus/PrivacyInfo.xcprivacy']}
end
