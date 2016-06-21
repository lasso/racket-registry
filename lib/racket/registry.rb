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
    def initialize
      @resolved = {}
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
      key, proc, proc_args =
        ClassMethods.validate_usable([key, self, proc, block])
      singleton_class.instance_eval do
        define_method(key) { proc.call(*proc_args) }
      end && nil
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
      key, proc, proc_args =
        ClassMethods.validate_usable([key, self, proc, block])
      singleton_class.instance_eval do
        define_method(key) do
          return @resolved[key] if @resolved.key?(key)
          @resolved[key] = proc.call(*proc_args)
        end
      end && nil
    end

    alias singleton register_singleton

    # Racket Registry class methods
    module ClassMethods
      # Validates that the parameters sent to the registry is usable.
      #
      # @param [Array] args
      # @return [Array]
      def self.validate_usable(args)
        key = validate_key(args[0], args[1])
        proc = validate_proc(args[2], args[3])
        [key, proc, proc.arity.zero? ? [] : [obj]]
      end

      def self.validate_key(key, obj)
        sym = key.to_sym
        insp = key.inspect
        raise "Invalid key #{insp}" if
          Racket::Registry.public_methods.include?(sym) ||
          /^[a-z\_]{1}[\d\w\_]*$/ !~ sym
        raise "Key #{insp} already registered" if obj.respond_to?(key)
        sym
      end

      def self.validate_proc(proc, block)
        return proc if proc.respond_to?(:call)
        return block if block.respond_to?(:call)
        raise 'No proc/block given'
      end

      private_class_method :validate_key, :validate_proc
    end
  end
end
