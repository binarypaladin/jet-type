require "spec_helper"

module Jet
  class TypeSpec < Minitest::Spec
    let(:coercible_type) do
      Type.with(strict_type) do
        coerce do
          match { |input| input.respond_to?(:to_i) }
          transform(&:to_i)
        end
      end
    end

    let(:strict_type) { Type.new(:integer, ::Integer) }

    it "creates a strict type" do
      _(strict_type.types).must_equal([::Integer])
      r = strict_type.(1)
      assert r.success?
      _(r.output).must_equal(1)

      r = strict_type.(1.0)
      assert r.failure?
    end

    it "creates a coercible type from a stict type" do
      r = coercible_type.(1.0)
      assert r.success?
      _(r.output).must_equal(1)
    end

    it "can have multiple types" do
      t = Type.new(:boolaen, TrueClass, FalseClass)

      r = t.(true)
      assert r.success?
      _(r.output).must_equal(true)

      r = t.(false)
      assert r.success?
      _(r.output).must_equal(false)

      r = t.(nil)
      assert r.failure?
    end

    it "can prepend coercions" do
      hex_output = "0xF"
      match_proc = proc { |input| input.is_a?(::String) && input.match?(/0x\h+/) }
      transform_proc = proc { |input| input.to_i(16) }

      hex_string_after = Type.with(coercible_type) do
        coerce do
          match(&match_proc)
          transform(&transform_proc)
        end
      end

      r = hex_string_after.(hex_output)
      assert r.success?
      _(r.output).must_equal(0)

      hex_string_before = Type.with(coercible_type) do
        coerce(:before) do
          match(&match_proc)
          transform(&transform_proc)
        end
      end

      r = hex_string_before.(hex_output)
      assert r.success?
      _(r.output).must_equal(15)
    end

    it "can filter output" do
      nil_blank_stripped_string = Type.new(:string, ::String) do
        filter do |output|
          output.strip.yield_self { |o| o.empty? ? nil : o }
        end
      end

      r = nil_blank_stripped_string.("\n")
      assert r.failure?
      _(r.output.first).must_equal(:type_coercion_failure)

      r = nil_blank_stripped_string.maybe.("\n")
      assert r.success?
      _(r.output).must_be_nil
    end

    it "returns a `maybe` type" do
      refute strict_type.(nil).success?
      maybe = strict_type.maybe
      _(maybe.types).must_equal([::Integer, NilClass])

      r = maybe.(nil)
      assert r.success?
      assert r.output.nil?
    end
  end
end
