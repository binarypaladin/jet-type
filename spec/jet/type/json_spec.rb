require "spec_helper"

module Jet
  class Type
    class JSONSpec < Minitest::Spec
      it "coerces decimal values" do
        r = JSON[:decimal].(3.1415)
        assert r.success?
        _(r.output).must_equal(BigDecimal("3.1415"))
      end

      it "coerces float values" do
        r = JSON[:float].(BigDecimal("3.1415"))
        assert r.success?
        _(r.output).must_equal(3.1415)
      end

      it "coerces integer values" do
        r = JSON[:integer].(3.0)
        assert r.success?
        _(r.output).must_equal(3)

        r = JSON[:integer].(3.1415)
        assert r.failure?
        _(r.errors.first).must_equal(:number_too_precise)
      end
    end
  end
end
