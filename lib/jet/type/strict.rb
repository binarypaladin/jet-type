# frozen_string_literal: true

require "bigdecimal"
require "date"
require "time"

module Jet
  class Type
    module Strict
      extend Core::InstanceRegistry
      type Type

      [
        Array = Type.new(:array, ::Array),
        Boolean = Type.new(:boolean, TrueClass, FalseClass),
        Date = Type.new(:date, ::Date),
        Decimal = Type.new(:decimal, BigDecimal),
        Float = Type.new(:float, ::Float),
        Hash = Type.new(:hash, ::Hash),
        Integer = Type.new(:integer, ::Integer),
        String = Type.new(:string, ::String),
        Time = Type.new(:time, ::Time)
      ].map { |t| [t.name, t] }.to_h.tap { |types| register(types).freeze }
    end
  end
end
