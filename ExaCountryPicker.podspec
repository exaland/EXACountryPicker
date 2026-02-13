Pod::Spec.new do |s|
  s.name         = 'EXACountryPicker'
  s.version      = '1.0.4'
  s.summary      = "EXACountryPicker is a swift country picker controller. Provides country name, ISO 3166 country codes, and calling codes"
  s.homepage     = "https://github.com/exaland/EXACountryPicker"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Exaland Concept"  => "https://github.com/exaland/EXACountryPicker" }
  s.social_media_url   = "https://twitter.com/exaland"

  s.platform     = :ios
  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/exaland/EXACountryPicker.git", :tag => '1.0.4' }
  s.source_files  = 'Sources/EXACountryPicker/*.swift'
  s.resources = ['Sources/EXACountryPicker/assets.bundle', 'Sources/EXACountryPicker/CallingCodes.plist']
  s.requires_arc = true
end
