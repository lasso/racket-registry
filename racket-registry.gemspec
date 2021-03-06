# frozen_string_literal: true

# Racket Registry - a simple dependency injection container
# Copyright (C) 2016-2019  Lars Olsson <lasso@lassoweb.se>
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

description = <<~DESCRIPTION
  Racket Registry is an easy-to-use container lib for most of your dependency
  injection container needs.
DESCRIPTION

files = test_files = nil
Dir.chdir(__dir__) do
  files = Dir.glob('lib/**/*')
  files.concat(%w[COPYING.AGPL Rakefile README.md])
  test_files = Dir.glob('spec/**/*')
end

summary = 'Racket Registry - a simple dependency injection container'

Gem::Specification.new do |s|
  s.name                  = 'racket-registry'
  s.email                 = 'lasso@lassoweb.se'
  s.homepage              = 'https://git.lassoweb.se/lasso/racket-registry'
  s.license               = 'AGPL-3.0'
  s.authors               = ['Lars Olsson']
  s.version               = '0.6'
  s.date                  = Time.now.strftime('%Y-%m-%d')
  s.summary               = summary
  s.description           = description
  s.files                 = files
  s.platform              = Gem::Platform::RUBY
  s.require_path          = 'lib'
  s.required_ruby_version = '>= 2.4'
  s.test_files            = test_files

  s.add_development_dependency('codecov', '~>0.1')
  s.add_development_dependency('minitest', '~>5.0')
  s.add_development_dependency('rake', '~>12')
  s.add_development_dependency('simplecov', '~>0.12')
  s.add_development_dependency('yard', '~>0.9')
end
