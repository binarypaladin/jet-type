# frozen_string_literal: true

require "jet/core"
require "jet/type/coercion"
require "jet/type/version"

module Jet
  class Type
    def self.with(type, *types, name: nil, &blk)
      Jet.type_check!("`type`", type, Type)
      new(
        name || type.name,
        *[type.types, types].flatten.uniq,
        coercions: type.coercions,
        filter: type.filter,
        &blk
      )
    end

    attr_reader :coercions, :name, :types

    def initialize(name, *types, coercions: [], filter: nil, &blk)
      @name = name.to_sym
      @coercions = coercions.dup
      @filter = filter
      @types = Jet.type_check_each!("`types`", types, Class, Module)
      instance_eval(&blk) if block_given?
      @coercions.freeze
    end

    def call(input)
      return process_output(input) if type_match?(input)

      @coercions.each do |coercion|
        result = coercion.(input)
        return process_output(result.output) if result.success?
        return result if result.failure? && result != :no_coercion_match
      end

      failure(input: input)
    end

    def filter(callable = nil, &blk)
      return @filter unless callable || block_given?
      @filter = Core.block_or_callable!(callable, &blk)
    end

    def inspect
      "#<#{self.class.name}:#{name}>"
    end

    def maybe
      @maybe ||= maybe? ? self : self.class.with(self, NilClass)
    end

    def maybe?
      types.include?(NilClass)
    end

    def to_sym
      name
    end

    def type_match?(obj)
      types.any? { |t| obj.is_a?(t) }
    end

    private

    def coerce(at = :after, &blk)
      coercion = Coercion.new(&blk)
      if at == :before
        @coercions = [coercion] + coercions
      elsif at == :after
        @coercions += [coercion]
      else
        raise ArgumentError, "`at` must equal :before or :after"
      end
    end

    def failure(error = :type_coercion_failure, **context)
      Result.failure([error, name], context.merge(types: types))
    end

    def process_output(output)
      output &&= @filter ? @filter.(output) : output
      return failure(output: output) unless type_match?(output)
      Result.success(output)
    end
  end
end

require "jet/core/instance_registry"
require "jet/type/strict"
require "jet/type/http"
require "jet/type/json"
