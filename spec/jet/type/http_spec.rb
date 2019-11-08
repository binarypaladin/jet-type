require "spec_helper"

module Jet
  class Type
    class HTTPSpec < Minitest::Spec
      it "coerces boolean values" do
        r = HTTP[:boolean].("TRUE")
        assert r.success?
        _(r.output).must_equal(true)

        r = HTTP[:boolean].("0")
        assert r.success?
        _(r.output).must_equal(false)

        r = HTTP[:boolean].("text")
        assert r.failure?
      end

      it "coerces date values" do
        r = HTTP[:date].("2014-10-20")
        assert r.success?
        _(r.output).must_equal(Date.new(2014, 10, 20))

        r = HTTP[:date].("Last year.")
        assert r.failure?
        _(r.errors).must_be_empty

        r = HTTP[:date].("2014-13-20")
        assert r.failure?
        _(r.errors.first).must_equal(:invalid_date)
      end

      it "coerces decimal values" do
        r = HTTP[:decimal].("3.1415")
        assert r.success?
        _(r.output).must_equal(BigDecimal("3.1415"))

        r = HTTP[:decimal].("NaN")
        assert r.failure?
      end

      it "coerces float values" do
        r = HTTP[:float].("3.1415")
        assert r.success?
        _(r.output).must_equal(3.1415)

        r = HTTP[:float].("NaN")
        assert r.failure?
      end

      it "coerces integer values" do
        r = HTTP[:integer].("3.0000")
        assert r.success?
        _(r.output).must_equal(3)

        r = HTTP[:integer].("3.1415")
        assert r.failure?
      end

      it "coerces time values" do
        utc_time = Time.parse("2012-03-29T11:57:13-00:00")
        local_time = Time.parse("2012-03-29T03:57:13-08:00")

        {
          "2012-03-29 11:57:13" => utc_time,
          "2012-03-29T03:57:13-08:00" => local_time,
          "2012-03-29T11:57:13Z" => utc_time
        }.each do |valid_input, expected_time|
          r = HTTP[:time].(valid_input)
          assert r.success?
          _(r.output).must_equal(expected_time)
        end

        r = HTTP[:time].("5 o'clock somewhere.")
        assert r.failure?
        _(r.errors).must_be_empty

        r = HTTP[:time].("2012-03-32 11:57:13")
        assert r.failure?
        _(r.errors.first).must_equal(:invalid_date)

        r = HTTP[:time].("2012-03-29T25:57:13Z")
        assert r.failure?
        _(r.errors.first).must_equal(:invalid_hours)

        r = HTTP[:time].("2012-03-29T11:61:13Z")
        assert r.failure?
        _(r.errors.first).must_equal(:invalid_minutes)

        r = HTTP[:time].("2012-03-29T11:57:92Z")
        assert r.failure?
        _(r.errors.first).must_equal(:invalid_seconds)

        r = HTTP[:time].("2012-03-31T11:57:13-13:45")
        assert r.failure?
        _(r.errors.first).must_equal(:invalid_utc_offest)
      end
    end
  end
end
