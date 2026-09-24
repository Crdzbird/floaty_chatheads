#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'floaty_chatheads_ios'
  s.version          = '2.1.0'
  s.summary          = 'An iOS implementation of the floaty_chatheads plugin.'
  s.description      = <<-DESC
  An iOS implementation of the floaty_chatheads plugin.
                       DESC
  s.homepage         = 'https://github.com/crdzbird/floaty_chatheads'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Crdzbird' => 'luisalfonsocb83@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'floaty_chatheads_ios/Sources/**/*.swift'
  s.resource_bundles = {
    'floaty_chatheads_ios_privacy' => ['floaty_chatheads_ios/Sources/floaty_chatheads_ios/PrivacyInfo.xcprivacy']
  }
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '6.1'
end
