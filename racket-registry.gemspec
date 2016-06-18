require 'rake'

registry_files = FileList['lib/**/*'].to_a
registry_files.concat(FileList['COPYING.AGPL', 'Rakefile', 'README.md'].to_a)

summary = 'Racket Registry - a simple dependency injection container'

description = <<EOS
Racket Registry is an easy-to-use container lib for most of your dependency
injection container needs.
EOS

Gem::Specification.new do |s|
  s.name                  = 'racket-registry'
  s.email                 = 'lasso@lassoweb.se'
  s.homepage              = 'https://github.com/lasso/racket-registry'
  s.license               = 'AGPL-3.0'
  s.authors               = ['Lars Olsson']
  s.version               = '0.1.0'
  s.date                  = Time.now.strftime('%Y-%m-%d')
  s.summary               = summary
  s.description           = description
  s.files                 = registry_files
  s.platform              = Gem::Platform::RUBY
  s.require_path          = 'lib'
  s.required_ruby_version = '>= 1.9.3'
  s.test_files            = FileList['spec/**/*'].to_a

  s.add_development_dependency('bacon', '~>1.2')
  s.add_development_dependency('codecov', '~>0.0.8')
  s.add_development_dependency('rake', '~>10')
  s.add_development_dependency('simplecov', '~>0.10')
  s.add_development_dependency('yard', '~>0')
end
