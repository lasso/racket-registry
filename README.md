[![Build Status](https://travis-ci.org/lasso/racket-registry.svg?branch=master)](https://travis-ci.org/lasso/racket-registry)&nbsp;&nbsp;&nbsp;&nbsp;[![Code Climate](https://codeclimate.com/github/lasso/racket-registry/badges/gpa.svg)](https://codeclimate.com/github/lasso/racket-registry)&nbsp;&nbsp;&nbsp;&nbsp;[![codecov.io](https://codecov.io/github/lasso/racket-registry/coverage.svg?branch=master)](https://codecov.io/github/lasso/racket-registry?branch=master)&nbsp;&nbsp;&nbsp;&nbsp;[![Gem Version](https://badge.fury.io/rb/racket-registry.svg)](http://badge.fury.io/rb/racket-registry)

# Racket Registry

## Why?
Racket Registry was originally intended for use in my home-made web framework, [racket](https://github.com/lasso/racket), but since there are no hard dependencies on anything else I realized that it might be better for it to live in its own gem.

The intention of the this library is to provide a very simple dependency injection container. Although not as useful in ruby as in less dynamic languages, I still think using a service container has its uses.

## How?
Racket Registry allows you to register two kinds of procs, non-singletons and singletons. Registering also means that the container gets a new public method corresponding to the key used when registering the proc.

```ruby
require 'racket/registry'

registry = Racket::Registry.new

# Registering a non-singleton proc
registry.register(:foo, lambda { Object.new })

# obj1 and obj2 will be two different objects
obj1 = registry.foo
obj2 = registry.foo

# Registering a singleton proc
registry.singleton(:bar, lambda { Object.new })

# obj1 and obj2 will be the same object
obj1 = registry.bar
obj2 = registry.bar
```

## Handling dependendencies within the registry

```ruby
class Simple
  def initialize(text)
    @text = text
  end
end

class NotSoSimple
  def initialize(text, simple_first, simple_second)
    @text = test
    @simple_first = simple_first
    @simple_second = simple_second
  end
end

require 'racket/registry'

registry = Racket::Registry.new

# When giving your block a parameter, the container will be inserted into it
# making it easy to get other entries in the container. The order of the registrations
# does not matter, the dependencies will not be resolved until
# explicly requested.
registry.singleton(
  :baz,
  lambda { |r| NotSoSimple.new('baz', r.foo, r.bar) }
)
registry.singleton(:bar, lambda { |r| Simple.new('bar') })
registry.singleton(:foo, lambda { |r| Simple.new('foo') })

 # registry.foo and registry.bar will be resolved on the first
 # call to registry.baz
registry.baz
```

## Block syntax

If you don't want to use a proc, you can also use a block when registering a callback.

```ruby
require 'racket/registry'

registry = Racket::Registry.new

# Proc syntax
registry.register(:foo, lambda { Object.new })

# Block syntax
registry.register(:foo) { Object.new }
```

## Limitations
When registering a proc, you must use a string/symbol as key. Since the registry is also defining a new public method, the key must not collide with any public method in Object or Racket::Registry.
