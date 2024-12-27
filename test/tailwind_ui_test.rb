# frozen_string_literal: true

require "test_helper"
require "tailwind_ui/jsx_to_erb"

class TailwindUiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TailwindUi::VERSION
  end

  def test_initialization
    jsx_to_erb = TailwindUi::JsxToErb.new("file contents")
    assert_instance_of TailwindUi::JsxToErb, jsx_to_erb
  end
end
