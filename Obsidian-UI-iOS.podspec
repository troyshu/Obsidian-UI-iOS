Pod::Spec.new do |s|

  s.name             = "Obsidian-UI-iOS"
  s.version          = "1.0.0"
  s.summary          = "A collection of useful iOS user interface components and utilities for use in a wide range of projects."

  s.description      = "Obsidian UI is a collection of useful iOS user interface components and utilities for use in a wide range of projects.  For convenience, the classes have been bundled into one framework, ready to be dropped into your app."
  s.homepage         = "http://tendigi.github.io/obsidian-ui-ios"

  s.license          = 'MIT'
  s.author           = { "Nick Lee" => "nick@tendigi.com" }
  s.source           = { :git => "https://github.com/TENDIGI/Obsidian-UI-iOS.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.4'
  s.requires_arc = true

  s.source_files = 'src/**/*'

end
