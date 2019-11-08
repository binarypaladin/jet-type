require "spec_helper"

module Jet
  class Type
    class StrictSpec < Minitest::Spec
      it "requires an array output" do
        v = %i[output]
        r = Strict[:array].(v)
        assert r.success?
        _(r.output).must_equal(v)

        r = Strict[:array].(key: "output")
        assert r.failure?
      end

      it "requires a boolean output" do
        v = false
        r = Strict[:boolean].(v)
        assert r.success?
        _(r.output).must_equal(v)

        r = Strict[:boolean].(nil)
        assert r.failure?
      end

      it "requires a date output" do
        v = Date.today
        r = Strict[:date].(v)
        assert r.success?
        _(r.output).must_equal(v)

        r = Strict[:date].("2019-01-01")
        assert r.failure?
      end

      it "requires a decimal output" do
        v = BigDecimal("3.1415")
        r = Strict[:decimal].(v)
        assert r.success?
        _(r.output).must_equal(v)

        r = Strict[:decimal].(3.1415)
        assert r.failure?
      end

      it "requires a float output" do
        v = 3.1415
        r = Strict[:float].(v)
        assert r.success?
        _(r.output).must_equal(v)

        r = Strict[:float].(BigDecimal("3.1415"))
        assert r.failure?
      end

      it "requires a hash output" do
        v = { key: "output" }
        r = Strict[:hash].(v)
        assert r.success?
        _(r.output).must_equal(v)

        r = Strict[:hash].(%i[output])
        assert r.failure?
      end

      it "requires a integer output" do
        v = 1
        r = Strict[:integer].(v)
        assert r.success?
        _(r.output).must_equal(v)

        r = Strict[:integer].(1.0)
        assert r.failure?
      end

      it "requires a string output" do
        v = "true"
        r = Strict[:string].(v)
        assert r.success?
        _(r.output).must_equal(v)

        r = Strict[:string].(true)
        assert r.failure?
      end

      it "requires a time output" do
        v = Time.now
        r = Strict[:time].(v)
        assert r.success?
        _(r.output).must_equal(v)

        r = Strict[:time].("2019-01-01T00:00:00Z")
        assert r.failure?
      end
    end
  end
end
