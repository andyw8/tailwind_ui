# frozen_string_literal: true

require "test_helper"
require "nokogiri"
require "tailwind_ui/jsx_to_erb"

class TestTailwindUi < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TailwindUi::VERSION
  end

  def test_conversion
    # input = File.read("test/fixtures/simple.jsx")

    result = TailwindUi::JsxToErb.from_path("test/fixtures/simple.jsx").full + "\n"

    expected = File.read("test/fixtures/simple.html.erb")

    assert_equal expected, result
  end
end
