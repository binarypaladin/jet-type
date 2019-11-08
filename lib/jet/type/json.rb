# frozen_string_literal: true

module Jet
  class Type
    module JSON
      extend Core::InstanceRegistry
      type Type

      module Matcher
        SUPPORTED_NUMERICS = [::BigDecimal, ::Float, ::Integer].freeze

        Numeric = proc do |input|
          SUPPORTED_NUMERICS.any? { |type| input.is_a?(type) }
        end
      end

      Decimal = Type.with(HTTP::Decimal) do
        coerce(:before) do
          match(&Matcher::Numeric)
          transform do |input|
            case input
            when ::Float
              BigDecimal(input, ::Float::DIG)
            else
              BigDecimal(input)
            end
          end
        end
      end

      Float = Type.with(Strict::Float) do
        coerce do
          match(&Matcher::Numeric)
          transform(&:to_f)
        end
      end

      Integer = Type.with(Strict::Integer) do
        coerce do
          match(&Matcher::Numeric)
          transform(&:to_i)
          check(:number_too_precise) { |output, input| input == output }
        end
      end

      register(
        **HTTP.to_h,
        decimal: Decimal,
        float: Float,
        integer: Integer
      ).freeze
    end
  end
end
