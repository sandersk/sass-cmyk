Gem::Specification.new do |gem|
  gem.name = 'sass-cmyk'
  gem.summary = 'A plugin for Sass that provides preprocessing for CMYK colors, including some basic color manipulation functions'
  gem.description = <<-DESC
    Need to preprocess CMYK colors with Sass? The sass-cmyk plugin lets you construct CMYK color objects with cmyk(), 
    adds support for performing math operations (+, *, /) on CMYK colors, and provides functions for mixing, lightening, and darkening
    colors. sass-cmyk outputs CMYK color values using cmyk() function syntax supported by AntennaHouse and PrinceXML PDF formatters,
    making it a great fit for doing print typesetting with CSS.
  DESC

  gem.version = '0.0.1'
  gem.authors = ['Sanders Kleinfeld']
  gem.email = 'sanders@oreilly.com'
  gem.homepage = 'https://github.com/sandersk/sass-cmyk'
  gem.license = 'MIT'
  gem.files = ['lib/sass-cmyk.rb']
  gem.required_ruby_version = '>= 1.8.7'
  gem.add_development_dependency "rspec"
  gem.add_runtime_dependency "sass"
end