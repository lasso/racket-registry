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

require 'bacon'
require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require_relative '../lib/racket/registry.rb'

describe 'Racket::Registry' do
  registry = Racket::Registry.new

  it 'should be able to register non-singleton entries using a proc' do
    registry.register('one', -> { Object.new })
    registry.should.respond_to(:one)
    obj1 = registry.one
    obj2 = registry.one
    obj1.object_id.should.not.equal(obj2.object_id)
  end

  it 'should be able to register singleton entries using a proc' do
    registry.singleton('two', -> { Object.new })
    registry.should.respond_to(:two)
    obj1 = registry.two
    obj2 = registry.two
    obj1.object_id.should.equal(obj2.object_id)
  end

  it 'should be able to register non-singleton entries using a block' do
    registry.register('three') { Object.new }
    registry.should.respond_to(:three)
    obj1 = registry.three
    obj2 = registry.three
    obj1.object_id.should.not.equal(obj2.object_id)
  end

  it 'should be able to register singleton entries using a block' do
    registry.singleton('four') { Object.new }
    registry.should.respond_to(:four)
    obj1 = registry.four
    obj2 = registry.four
    obj1.object_id.should.equal(obj2.object_id)
  end

  it 'should block invalid entries' do
    -> { registry.register('invalid') }.should.raise(RuntimeError)
  end
end
