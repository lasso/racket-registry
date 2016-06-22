# Racket Registry - a simple dependency injection container
# Copyright (C) 2016  Lars Olsson <lasso@lassoweb.se>
#
# This file is part of Racket Registry.
#
# Racket Registry is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Racket Registry is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Racket Registry.  If not, see <http://www.gnu.org/licenses/>.

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
  s.version               = '0.2.1'
  s.date                  = Time.now.strftime('%Y-%m-%d')
  s.summary               = summary
  s.description           = description
  s.files                 = registry_files
  s.platform              = Gem::Platform::RUBY
  s.require_path          = 'lib'
  s.required_ruby_version = '>= 1.9.3'
  s.test_files            = FileList['spec/**/*'].to_a

  s.add_development_dependency('bacon', '~>1.2')
  s.add_development_dependency('codecov', '~>0.1.5')
  s.add_development_dependency('rake', '~>11')
  s.add_development_dependency('simplecov', '~>0.11')
  s.add_development_dependency('yard', '~>0')
end
