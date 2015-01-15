Pod::Spec.new do |s|
  s.name             = "DMPathBar"
  s.version          = "0.1.0"
  s.summary          = "Yosemite like PathBar Control for Mac (like in XCode)"
  s.homepage         = "https://github.com/malcommac/DMPathBar"
  s.license          = 'MIT'
  s.author           = 'Daniele Margutti'
  s.source           = { :git => "https://github.com/malcommac/DMPathBar.git", :tag => s.version.to_s }

  s.platform     = :osx, '10.9'
  s.requires_arc = true

  s.source_files = 'DMPathBar'

  s.frameworks = 'Cocoa'
end