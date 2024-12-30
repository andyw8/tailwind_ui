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

  def test_with_data
    code = <<~JSX
      const stats = [
        { label: 'Founded', value: '2021' },
        // More stats...
      ]

      export default function Example() {
        return (
          <div className="bg-gray-900 py-24 sm:py-32">
          </div>
        )
      }
    JSX

    data = TailwindUi::JsxToErb.new(code).data

    expected = <<~RUBY
      <% stats = [
        { label: 'Founded', value: '2021' },
         # More stats...
      ] %>
    RUBY

    assert_equal expected, data
  end

  def test_against_real_tailwind_ui
    skip "Skipping since SOURCE_PATH is not set" unless ENV["SOURCE_PATH"]

    Dir.glob("#{ENV.fetch("SOURCE_PATH")}/**/*.jsx").each do |path|
      TailwindUi::JsxToErb.from_path(path).full
      # puts "OK: #{path}"
    rescue TailwindUi::NeedsImports
      # puts "Needs imports: #{path}"
      next
    rescue TailwindUi::NeedsData
      puts "Needs data: #{path}"
      next
    rescue TailwindUi::NotYetSupported
      puts "Not supported yet: #{path}"
      next
    rescue TailwindUi::Special
      # puts "Special: #{path}"
      next
    rescue TailwindUi::ErbError
      # puts "ErbError: #{path}"
      next
    rescue SyntaxError
      puts "Syntax: #{path}"
      next
    rescue TailwindUi::ClipPathNotYetSupported
      # puts "Clippath not yet supported: #{path}"
      next
    end
  end
end
