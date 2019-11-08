# frozen_string_literal: true

module Jet
  class Type
    module HTTP
      extend Core::InstanceRegistry
      type Type

      module Matcher
        Numeric = proc do |input|
          input.is_a?(::String) && input.match?(/\A-?\d+(\.\d+)?\Z/)
        end
      end

      DATE_PATTERN = /\d{4}(-\d{2}){2}/.freeze
      TIME_PATTERN = /(\d{2}:){2}\d{2}(\.0{1-3})?(Z?|[-+]\d{2}:\d{2})?/.freeze
      DATETIME_PATTERN = /#{DATE_PATTERN}[ T]#{TIME_PATTERN}/.freeze

      FALSE_VALUES = %w[0 f false F FALSE n no N NO].freeze
      TRUE_VALUES = %w[1 t true T TRUE y yes Y YES].freeze

      Boolean = Type.with(Strict::Boolean) do
        coerce do
          match { |input| TRUE_VALUES.any? { |v| input == v } }
          transform { true }
        end

        coerce do
          match { |input| FALSE_VALUES.any? { |v| input == v } }
          transform { false }
        end
      end

      Date = Type.with(Strict::Date) do
        coerce do
          match { |input| input.is_a?(String) && input.match?(/\A#{DATE_PATTERN}\Z/) }

          transform do |input|
            args = input.split("-").map(&:to_i)
            transformation_failure!(input, :invalid_date) unless ::Date.valid_date?(*args)
            ::Date.new(*args)
          end
        end
      end

      Decimal = Type.with(Strict::Decimal) do
        coerce do
          match(&Matcher::Numeric)
          transform { |input| BigDecimal(input) }
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
          match { |input| input.is_a?(::String) && input.match?(/\A-?\d+(\.0+)?\Z/) }
          transform(&:to_i)
        end
      end

      Time = Type.with(Strict::Time) do
        coerce do
          match { |input| input.is_a?(String) && input.match?(/\A#{DATETIME_PATTERN}\Z/) }

          transform do |input|
            date, time = input.split(/[ T]/)
            date_args = date.split("-").map(&:to_i)
            transformation_failure!(input, :invalid_date) unless ::Date.valid_date?(*date_args)

            h = time[0..1].to_i
            transformation_failure!(input, :invalid_hours) if h > 24
            m = time[3..4].to_i
            transformation_failure!(input, :invalid_minutes) if m > 59
            s = time[6..7].to_i
            transformation_failure!(input, :invalid_seconds) if s > 59

            offset =
              if (idx = time.index(/[-+]/))
                time[idx..-1].tap do |o|
                  transformation_failure!(input, :invalid_utc_offest) if
                    !%w[00 15 30 45].include?(o[4..5]) || o[1..2].to_i > 12
                end
              else
                "+00:00"
              end

            ::Time.new(*date_args, h, m, s, offset)
          end
        end
      end

      register(
        **Strict.to_h,
        boolean: Boolean,
        date: Date,
        decimal: Decimal,
        float: Float,
        integer: Integer,
        time: Time
      ).freeze
    end
  end
end
