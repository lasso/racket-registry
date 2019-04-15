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

# Racket namespace
module Racket
  # Racket Registry namespace
  class Registry
    class << self
      # Returns a new registry with all items in the map registered as
      # non-singleton procs.
      #
      # @param [Hash] map
      # @return [Racket::Registry]
      def with_map(map)
        registry = new
        map.each_pair { |key, value| registry.register(key, value) }
        registry
      end

      # Returns a new registry with all items in the map registered as
      # singleton procs.
      #
      # @param [Hash] map
      # @return [Racket::Registry]
      def with_singleton_map(map)
        registry = new
        map.each_pair { |key, value| registry.register_singleton(key, value) }
        registry
      end

      alias singleton_map with_singleton_map
    end

    # Removes the callback specified by +key+ from the registry.
    #
    # @param [String|Symbol] key
    # @return [nil]
    def forget(key)
      Helper.forget(obj: self, key: key)
    end

    # Removes all callbacks from the registry.
    def forget_all
      Helper.forget_all(obj: self)
    end

    # Registers a new callback in the registry. This will add a new method
    # matching +key+ to the registry that can be used both outside the
    # registry and when registering other callbacks dependant of the
    # current entry. Results from the callback will not be cached, meaning
    # that the callback may return a different object every time.
    #
    # @param [String|Symbol] key
    # @param [Proc|nil] proc
    # @return [nil]
    def register(key, proc = nil, &block)
      Helper.register(obj: self, key: key, proc: proc, block: block)
    end

    # Registers a new callback in the registry. This will add a new method
    # matching +key+ to the registry that can be used both outside the
    # registry and when registering other callbacks dependant of the
    # current entry. Results from the callnack will be cached, meaning
    # that the callback will return the same object every time.
    #
    # @param [String|Symbol] key
    # @param [Proc|nil] proc
    # @return [nil]
    def register_singleton(key, proc = nil, &block)
      Helper.register_singleton(obj: self, key: key, proc: proc, block: block)
    end

    alias singleton register_singleton

    # Private helper module for Racket Registry
    module Helper
      # Private method - do not call
      def self.forget(options)
        obj, methods, key = validate_existing(options)
        unless methods.include?(key)
          raise KeyNotRegisteredError,
                "Key #{key} is not registered"
        end
        obj.singleton_class.instance_eval do
          @resolved.delete(key) if defined?(@resolved)
          remove_method(key)
        end && nil
      end

      # Private method - do not call
      def self.forget_all(options)
        obj, methods, = validate_existing(options)
        obj.singleton_class.instance_eval do
          @resolved.clear if defined?(@resolved)
          methods.each { |meth| remove_method(meth) }
        end && nil
      end

      # Private method - do not call
      def self.register(options)
        key, proc, proc_args, obj = validate_usable(options)
        obj.define_singleton_method(key) do
          proc.call(*proc_args)
        end && nil
      end

      # Private method - do not call
      def self.register_singleton(options)
        key, proc, proc_args, obj = validate_usable(options)
        resolved = resolved(options[:obj])
        obj.define_singleton_method(key) do
          return resolved[key] if resolved.key?(key)
          resolved[key] = proc.call(*proc_args)
        end && nil
      end

      def self.resolved(obj)
        obj.singleton_class.instance_eval { @resolved ||= {} }
      end

      def self.validate_existing(options)
        result = [options[:obj]]
        result << result.first.singleton_methods
        key = options.fetch(:key, nil)
        result << key.to_sym if key
        result
      end

      def self.validate_key(key, obj)
        sym = key.to_sym
        insp = key.inspect
        raise KeyAlreadyRegisteredError, "Key #{insp} already registered" if
          obj.singleton_methods.include?(sym)
        raise InvalidKeyError, "Invalid key #{insp}" if
          obj.public_methods.include?(sym) ||
          /^[a-z_][\d\w_]*$/ !~ sym
        sym
      end

      def self.validate_callback(proc, block)
        return proc if proc.respond_to?(:call)
        return block if block.respond_to?(:call)
        raise InvalidCallbackError, 'Invalid callback'
      end

      def self.validate_usable(options)
        obj = options[:obj]
        key = validate_key(options[:key], obj)
        proc = validate_callback(options[:proc], options[:block])
        [key, proc, proc.arity.zero? ? [] : [obj], obj]
      end

      private_class_method :resolved, :validate_callback,
                           :validate_existing, :validate_key,
                           :validate_usable
    end

    private_constant :Helper

    # Exception class used when a user tries to register an
    # invalid callback.
    class InvalidCallbackError < ArgumentError
    end

    # Exception class used when a user tries to register an
    # invalid key.
    class InvalidKeyError < ArgumentError
    end

    # Exception class used when a user tries to register a key
    # that is already registered.
    class KeyAlreadyRegisteredError < ArgumentError
    end

    # Exception class used when a user is requesting to forget
    # a key that is not registered.
    class KeyNotRegisteredError < ArgumentError
    end
  end
end
