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

# Racket namespace
module Racket
  # Racket Registry namespace
  class Registry
    # Removes all registered callback from the registry.
    def clear
      self.class.instance_variable_get(:@mod).clear
    end

    # Removes the callback specified by +key+ from the registry.
    #
    # @param [String|Symbol] key
    # @return [nil]
    def forget(key)
      self.class.instance_variable_get(:@mod).forget(obj: self, key: key)
    end

    # Registers a new proc in the registry. This will add a new method
    # matching +key+ to the registry that can be used both outside the
    # registry and when registering other procs dependant of the
    # current entry. Results from the proc will not be cached, meaning
    # that the proc may return a different object every time.
    #
    # @param [String|Symbol] key
    # @param [Proc|nil] proc
    # @return [nil]
    def register(key, proc = nil, &block)
      self.class.instance_variable_get(:@mod).register(
        obj: self, key: key, proc: proc, block: block
      )
    end

    # Registers a new proc in the registry. This will add a new method
    # matching +key+ to the registry that can be used both outside the
    # registry and when registering other procs dependant of the
    # current entry. Results from the proc will be cached, meaning
    # that the proc will return the same object every time.
    #
    # @param [String|Symbol] key
    # @param [Proc|nil] proc
    # @return [nil]
    def register_singleton(key, proc = nil, &block)
      self.class.instance_variable_get(:@mod).register_singleton(
        obj: self, key: key, proc: proc, block: block
      )
    end

    alias singleton register_singleton

    @mod = Module.new do
      def self.forget(options)
        key = options[:key].to_sym
        options[:obj].singleton_class.instance_eval do
          @resolved.delete(key) if defined?(@resolved)
          remove_method key
        end
      end

      def self.register(options)
        key, proc, proc_args, obj = validate_usable(options)
        obj.define_singleton_method(key) do
          proc.call(*proc_args)
        end && nil
      end

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

      def self.validate_key(key, obj)
        sym = key.to_sym
        insp = key.inspect
        raise InvalidKeyError, "Invalid key #{insp}" if
          Racket::Registry.public_methods.include?(sym) ||
          /^[a-z\_]{1}[\d\w\_]*$/ !~ sym
        raise KeyAlreadyRegisteredError, "Key #{insp} already registered" if
          obj.respond_to?(key)
        sym
      end

      def self.validate_proc(proc, block)
        return proc if proc.respond_to?(:call)
        return block if block.respond_to?(:call)
        raise 'No proc/block given'
      end

      def self.validate_usable(options)
        obj = options[:obj]
        key = validate_key(options[:key], obj)
        proc = validate_proc(options[:proc], options[:block])
        [key, proc, proc.arity.zero? ? [] : [obj], obj]
      end

      private_class_method :resolved, :validate_key, :validate_proc,
                           :validate_usable
    end

    # Exception class used when an invalid key is used.
    class InvalidKeyError < ArgumentError
    end

    # Exception class used when an invalid proc/block is used.
    class InvalidProcError < ArgumentError
    end

    # Exception class used when a key is already registered.
    class KeyAlreadyRegisteredError < ArgumentError
    end
  end
end
