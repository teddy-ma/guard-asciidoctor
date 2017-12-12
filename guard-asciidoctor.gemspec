# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/asciidoctor/version'

Gem::Specification.new do |spec|
  spec.name          = 'guard-asciidoctor'
  spec.version       = Guard::AsciidoctorVersion::VERSION
  spec.authors       = ['Ma Lucheng']
  spec.email         = ['mlc880926@gmail.com']
  spec.summary       = %q{asciidoctor guard}
  spec.description   = %q{asciidoctor guard}
  spec.homepage      = 'https://github.com/teddy-ma/guard-asciidoctor'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.4'

  spec.add_dependency 'guard', '~> 2.0'
  spec.add_dependency 'guard-compat', '~> 1.1'
  spec.add_dependency 'asciidoctor'
  spec.add_dependency 'asciidoctor-pdf'

end
