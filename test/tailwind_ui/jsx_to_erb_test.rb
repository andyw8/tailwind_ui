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

  def test_class_name_handling
    code = <<~JSX
      export default function Example() {
        return (
          <div className="foo bar">
            Hello, world!
          </div>
        )
      }
    JSX

    expected = <<~JSX
      <div class="foo bar">
        Hello, world!
      </div>
    JSX

    result = TailwindUi::JsxToErb.new(code).full

    assert_equal expected, result
  end

  def test_images
    code = <<~JSX
      export default function Example() {
        return (
          <img
            width={158}
            height={48}
          />
        )
      }
    JSX

    expected = <<~JSX
      <img
        width="158"
        height="48"
      />
    JSX

    result = TailwindUi::JsxToErb.new(code).full

    assert_equal expected, result
  end

  def test_style
    code = <<~JSX
      export default function Example() {
        return (
          <div style={{ width: '37.5%' }} />
        )
      }
    JSX

    expected = <<~HTML
      <div style="width: '37.5%'" />
    HTML

    result = TailwindUi::JsxToErb.new(code).full

    assert_equal expected, result
  end

  def test_jsx_comments
    code = <<~JSX
      export default function Example() {
        return (
          <div>
          {/*
            line 1
            line 2
          */}
          </div>
        )
      }
    JSX

    expected = <<~JSX
      <div>
      <%#
        line 1
        line 2
      %>
      </div>
    JSX

    result = TailwindUi::JsxToErb.new(code).full

    assert_equal expected, result
  end

  def test_against_real_tailwind_ui
    skip "Skipping since SOURCE_PATH is not set" unless ENV["SOURCE_PATH"]

    Dir.glob("#{ENV.fetch("SOURCE_PATH")}/**/*.jsx").each do |path|
      TailwindUi::JsxToErb.from_path(path).full
      # puts "OK: #{path}"
    rescue TailwindUi::NotYetSupported
      # puts "Not supported yet: #{path}"
      next
    rescue TailwindUi::Special
      # puts "Special: #{path}"
      next
    rescue SyntaxError
      puts "Syntax: #{path}"
      next
    rescue TailwindUi::ClipPathNotYetSupported
      puts "Clippath not yet supported: #{path}"
      next
    end
  end
end
