Pod::Spec.new do |s|
  s.name             = 'filesaverplus'
  s.version          = '0.1.0'
  s.summary          = 'FileSaverPlus Flutter plugin — macOS support.'
  s.description      = <<-DESC
    Flutter plugin for saving files to the user-chosen location via NSSavePanel on macOS.
  DESC
  s.homepage         = 'https://github.com/devamitkumartiwari/filesaverplus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Amit Kumar Tiwari' => 'amtechnovation@gmail.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
