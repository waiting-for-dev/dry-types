# frozen_string_literal: true

require 'dry/core/deprecations'
require 'dry/types/builder'
require 'dry/types/result'
require 'dry/types/options'

module Dry
  module Types
    class Nominal
      include Type
      include Options
      include Builder
      include Printable
      include Dry::Equalizer(:primitive, :options, :meta, inspect: false)

      # @return [Class]
      attr_reader :primitive

      # @param [Class] primitive
      # @return [Type]
      def self.[](primitive)
        if primitive == ::Array
          Types::Array
        elsif primitive == ::Hash
          Types::Hash
        else
          self
        end
      end

      # @param [Type,Class] primitive
      # @param [Hash] options
      def initialize(primitive, **options)
        super
        @primitive = primitive
        freeze
      end

      # @return [String]
      def name
        primitive.name
      end

      # @return [false]
      def default?
        false
      end

      # @return [false]
      def constrained?
        false
      end

      # @return [false]
      def optional?
        false
      end

      # @param [BasicObject] input
      # @return [BasicObject]
      def call_unsafe(input)
        input
      end

      # @param [BasicObject] input
      # @return [BasicObject]
      def call_safe(input)
        input
      end

      # @param [Object] input
      # @param [#call,nil] block
      # @yieldparam [Failure] failure
      # @yieldreturn [Result]
      # @return [Result,Logic::Result] when a block is not provided
      # @return [nil] otherwise
      def try(input)
        success(input)
      end

      # @param (see Dry::Types::Success#initialize)
      # @return [Result::Success]
      def success(input)
        Result::Success.new(input)
      end

      # @param (see Failure#initialize)
      # @return [Result::Failure]
      def failure(input, error)
        unless error.is_a?(CoercionError)
          raise ArgumentError, "error must be a CoercionError"
        end
        Result::Failure.new(input, error)
      end

      # Checks whether value is of a #primitive class
      # @param [Object] value
      # @return [Boolean]
      def primitive?(value)
        value.is_a?(primitive)
      end

      def coerce(input, &_block)
        if primitive?(input)
          input
        elsif block_given?
          yield
        else
          raise CoercionError, "#{input.inspect} must be an instance of #{primitive}"
        end
      end

      def try_coerce(input)
        result = success(input)

        coerce(input) do
          result = failure(
            input,
            CoercionError.new("#{input.inspect} must be an instance of #{primitive}")
          )
        end

        if block_given?
          yield(result)
        else
          result
        end
      end

      # Return AST representation of a type nominal
      #
      # @api public
      #
      # @return [Array]
      def to_ast(meta: true)
        [:nominal, [primitive, meta ? self.meta : EMPTY_HASH]]
      end

      def lax
        self
      end
    end

    extend Dry::Core::Deprecations[:'dry-types']
    Definition = Nominal
    deprecate_constant(:Definition, message: "Nominal")
  end
end

require 'dry/types/array'
require 'dry/types/hash'
require 'dry/types/map'