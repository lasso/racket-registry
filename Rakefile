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

desc 'Run bacon tests'
task default: [:test]

desc 'Build yard docs'
task :doc do
  exec 'yard'
end

desc 'Show list of undocumented modules/classes/methods'
task :nodoc do
  exec 'yard stats --list-undoc'
end

desc 'Run tests'
task :test do
  exec 'ruby spec/racket_registry.rb'
end