# frozen_string_literal: true

module Jet
  class Type
    class Coercion
      def initialize(&blk)
        raise ArgumentError, "no block given" unless block_given?
        @checks = []
        @matchers = []
        instance_eval(&blk)
        raise ArgumentError, "no `match` blocks given" if @matchers.empty?
        @checks = @checks.freeze
        @matchers.freeze
        @transformer ||= proc { |input| input }
      end

      def call(input)
        return Result.failure(:no_coercion_match, input: input) unless match?(input)

        catch(:transformation_failure) do
          check_output(input, instance_exec(input, &@transformer))
        end
      end

      def check_output(input, output)
        @checks.each do |(check, error)|
          return coercion_check_failure(output, input, error) unless check.(output, input)
        end
        Result.success(output, input: input)
      end

      def coercion_check_failure(output, input, error)
        Result.failure(:coercion_check_failure, errors: error, input: input, output: output)
      end

      def match?(output)
        @matchers.any? { |blk| blk.(output) }
      end

      def transformation_failure(input, *errors)
        Result.failure(:transformation_failure, errors: errors, input: input)
      end

      def transformation_failure!(*args)
        throw :transformation_failure, transformation_failure(*args)
      end

      private

      def check(error = nil, &blk)
        @checks += [[blk, error]]
      end

      def match(&blk)
        @matchers += [blk]
      end

      def transform(&blk)
        @transformer = blk
      end
    end
  end
end
