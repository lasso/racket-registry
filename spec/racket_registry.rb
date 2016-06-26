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

describe 'Racket::Registry registration' do
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

  it 'should block invalid keys' do
    -> { registry.register('inspect') }
      .should.raise(Racket::Registry::InvalidKeyError)
      .message.should.equal('Invalid key "inspect"')
  end

  it 'should block already registered keys' do
    -> { registry.register('one', -> { Object.new }) }
      .should.raise(Racket::Registry::KeyAlreadyRegisteredError)
      .message.should.equal('Key "one" already registered')
  end

  it 'should block invalid block/procs' do
    -> { registry.register('invalid') }
      .should.raise(Racket::Registry::InvalidCallbackError)
      .message.should.equal('Invalid callback')
  end
end

describe 'Racket::Registry dependency handling' do
  # A very simple class
  class Simple
    attr_reader :text

    def initialize(text)
      @text = text
    end
  end

  # A somewhat complex class
  class NotSoSimple
    attr_reader :text, :simple_first, :simple_second

    def initialize(text, simple_first, simple_second)
      @text = text
      @simple_first = simple_first
      @simple_second = simple_second
    end
  end

  it 'should be able to resolve dependencies regardless of ' \
     'registration order' do
    registry = Racket::Registry.new

    foo = Simple.new('foo')
    bar = Simple.new('bar')

    registry.singleton(
      :baz,
      ->(r) { NotSoSimple.new('baz', r.foo, r.bar) }
    )
    registry.singleton(:bar, -> { bar })
    registry.singleton(:foo, -> { foo })

    baz = registry.baz
    baz.simple_first.object_id.should.equal(foo.object_id)
    baz.simple_second.object_id.should.equal(bar.object_id)
    registry.foo.object_id.should.equal(foo.object_id)
    registry.bar.object_id.should.equal(bar.object_id)
  end
end

describe 'Racket::Registry entry removal' do
  registry = Racket::Registry.new

  it 'should be able to forget a single entry' do
    obj = Object.new
    registry.register(:foo) { obj }
    registry.foo.object_id.should.equal(obj.object_id)
    registry.forget(:foo)
    -> { registry.foo }.should.raise(NoMethodError)
  end

  it 'should be able to forget all entries' do
    obj = Object.new
    registry.register(:foo) { obj }
    registry.register(:bar) { obj }
    registry.foo.object_id.should.equal(obj.object_id)
    registry.bar.object_id.should.equal(obj.object_id)
    registry.forget_all
    -> { registry.foo }.should.raise(NoMethodError)
    -> { registry.bar }.should.raise(NoMethodError)
  end

  it 'should fail to forget non-existing entries' do
    -> { registry.forget(:baz) }
      .should.raise(Racket::Registry::KeyNotRegisteredError)
      .message.should.equal('Key baz is not registered')
  end
end
