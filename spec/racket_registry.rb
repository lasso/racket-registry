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

require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require_relative '../lib/racket/registry.rb'

require 'minitest/autorun'

describe 'Racket::Registry registration' do
  before do
    @registry = Racket::Registry.new
  end

  it 'must be able to register non-singleton entries using a proc' do
    @registry.register('one', -> { Object.new })
    @registry.must_respond_to(:one)
    obj1 = @registry.one
    obj2 = @registry.one
    obj1.wont_be_same_as(obj2)
  end

  it 'must be able to register singleton entries using a proc' do
    @registry.singleton('two', -> { Object.new })
    @registry.must_respond_to(:two)
    obj1 = @registry.two
    obj2 = @registry.two
    obj1.must_be_same_as(obj2)
  end

  it 'must be able to register non-singleton entries using a block' do
    @registry.register('three') { Object.new }
    @registry.must_respond_to(:three)
    obj1 = @registry.three
    obj2 = @registry.three
    obj1.wont_be_same_as(obj2)
  end

  it 'must be able to register singleton entries using a block' do
    @registry.singleton('four') { Object.new }
    @registry.must_respond_to(:four)
    obj1 = @registry.four
    obj2 = @registry.four
    obj1.must_be_same_as(obj2)
  end

  it 'must block invalid keys' do
    -> { @registry.register('inspect') }
      .must_raise(Racket::Registry::InvalidKeyError)
      .message.must_equal('Invalid key "inspect"')
  end

  it 'must block already registered keys' do
    @registry.register('one', -> { Object.new })
    -> { @registry.register('one', -> { Object.new }) }
      .must_raise(Racket::Registry::KeyAlreadyRegisteredError)
      .message.must_equal('Key "one" already registered')
  end

  it 'must block invalid block/procs' do
    -> { @registry.register('invalid') }
      .must_raise(Racket::Registry::InvalidCallbackError)
      .message.must_equal('Invalid callback')
  end

end

describe 'Racket::Registry bulk registration' do
  it 'must be able to register non-singleton procs in bulk' do
    registry =
      Racket::Registry.with_map(
        one: -> { Object.new },
        two: -> { Object.new },
        three: -> { Object.new }
      )
    %i[one two three].each do |key|
      registry.must_respond_to(key)
      obj1 = registry.send(key)
      obj2 = registry.send(key)
      obj1.wont_be_same_as(obj2)
    end
  end

  it 'must be able to register singleton procs in bulk' do
    registry =
      Racket::Registry.with_singleton_map(
        one: -> { Object.new },
        two: -> { Object.new },
        three: -> { Object.new }
      )
    %i[one two three].each do |key|
      registry.must_respond_to(key)
      obj1 = registry.send(key)
      obj2 = registry.send(key)
      obj1.must_be_same_as(obj2)
    end
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

  it 'must be able to resolve dependencies regardless of ' \
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
    baz.simple_first.must_be_same_as(foo)
    baz.simple_second.must_be_same_as(bar)
    registry.foo.must_be_same_as(foo)
    registry.bar.must_be_same_as(bar)
  end
end

describe 'Racket::Registry entry removal' do
  before do
    @registry = Racket::Registry.new
  end

  it 'must be able to forget a single entry' do
    obj = Object.new
    @registry.register(:foo) { obj }
    @registry.foo.must_be_same_as(obj)
    @registry.forget(:foo)
    -> { @registry.foo }.must_raise(NoMethodError)
  end

  it 'must be able to forget all entries' do
    obj = Object.new
    @registry.register(:foo) { obj }
    @registry.register(:bar) { obj }
    @registry.foo.must_be_same_as(obj)
    @registry.bar.must_be_same_as(obj)
    @registry.forget_all
    -> { @registry.foo }.must_raise(NoMethodError)
    -> { @registry.bar }.must_raise(NoMethodError)
  end

  it 'must fail to forget non-existing entries' do
    -> { @registry.forget(:baz) }
      .must_raise(Racket::Registry::KeyNotRegisteredError)
      .message.must_equal('Key baz is not registered')
  end
end