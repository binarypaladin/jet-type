require "spec_helper"

module Jet
  class Type
    class CoercionSpec < Minitest::Spec
      let(:coercion) do
        Coercion.new do
          match { |input| input.is_a?(String) && input.match?(/\A\d+(\.\d+)\Z/) }
          transform(&:to_f)
        end
      end

      let(:y2k_coerion) do
        Coercion.new do
          match { |input| input.is_a?(String) && input.match?(/\d{4}(-\d{2}){2}/) }

          transform do |input|
            args = input.split("-").map(&:to_i)
            transformation_failure!(input, :invalid_date) unless ::Date.valid_date?(*args)
            ::Date.new(*args)
          end

          check(:before_y2k) { |output| output > Date.new(2000, 1, 1) }
        end
      end

      it "matches and transforms a valid input" do
        input = "3.1415"
        assert coercion.match?(input)
        r = coercion.(input)
        assert r.success?
        refute r.failure?
        _(r.output).must_equal(input.to_f)
        _(r[:input]).must_equal(input)
      end

      it "does not match an invalid input" do
        input = "Mr. T"
        refute coercion.match?(input)
        r = coercion.(input)
        assert r.failure?
        refute r.success?
        _(r.output).must_equal(:no_coercion_match)
        _(r[:input]).must_equal(input)
      end

      it "fails during transformation with specific errors" do
        r = y2k_coerion.("2000-01-32")
        assert r.failure?
        _(r.output).must_equal(:transformation_failure)
        _(r.errors.first).must_equal(:invalid_date)
      end

      it "checks transformed output output for validity" do
        r = y2k_coerion.("1999-12-31")
        assert r.failure?
        _(r.output).must_equal(:coercion_check_failure)
        _(r.errors.first).must_equal(:before_y2k)
      end
    end
  end
end
