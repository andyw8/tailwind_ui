# frozen_string_literal: true

require "test_helper"
require "tailwind_ui/jsx_to_erb"

class JsxToErbTest < Minitest::Test
  def test_basic
    code = <<~JSX
      export default function Example() {
        return (
          <div>
            Hello, world!
          </div>
        )
      }
    JSX

    expected = <<~JSX
      <div>
        Hello, world!
      </div>
    JSX

    result = TailwindUi::JsxToErb.new(code).full

    assert_equal expected, result
  end

  def test_against_real_tailwind_ui
    skip "Skipping since SOURCE_PATH is not set" unless ENV["SOURCE_PATH"]

    Dir.glob("#{ENV.fetch("SOURCE_PATH")}/**/*.jsx").each do |path|
      TailwindUi::JsxToErb.from_path(path).full
    rescue TailwindUi::NotYetSupported
      next
    end
  end
end
