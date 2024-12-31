# frozen_string_literal: true

require "test_helper"
require "tailwind_ui/markup"

class MarkupTest < Minitest::Test
  def test_indentation_removal
    # rubocop:disable Layout/HeredocIndentation
    markup = <<~HTML # rubocop:disable Layout/HeredocIndentation
        <div>
          a
        </div>
    HTML
    # rubocop:enable Layout/HeredocIndentation

    result = TailwindUi::Markup.new(markup).result

    expected = <<~HTML2
      <div>
        a
      </div>
    HTML2

    assert_equal expected, result.chomp
  end

  def test_style_attributes_with_double_braces
    code = <<~JSX
      <div style={{ width: '37.5%' }} />
    JSX

    expected = <<~HTML
      <div style="width: '37.5%'" />
    HTML

    result = TailwindUi::Markup.new(code).result.chomp

    assert_equal expected, result
  end

  def test_images
    code = <<~JSX
      <img
        width={158}
        height={48}
      />
    JSX

    expected = <<~JSX
      <img
        width="158"
        height="48"
      />
    JSX

    result = TailwindUi::Markup.new(code).result

    assert_equal expected, result.chomp
  end

  def test_jsx_keyword_handling
    code = <<~JSX
      <div className="foo bar" htmlFor="baz">
        Hello, world!
      </div>
    JSX

    expected = <<~JSX
      <div class="foo bar" for="baz">
        Hello, world!
      </div>
    JSX

    result = TailwindUi::Markup.new(code).result

    assert_equal expected, result.chomp
  end

  def test_jsx_comments
    code = <<~JSX
      <div>
      {/*
        line 1
        line 2
      */}
      </div>
    JSX

    expected = <<~JSX
      <div>
      <%#
        line 1
        line 2
      %>
      </div>
    JSX

    result = TailwindUi::Markup.new(code).result

    assert_equal expected, result.chomp
  end

  def test_ruby_code
    code = <<~JSX
      <div>
        {stats.map((item) => (
          <dd>foo</dd>
        ))}
      </div>
    JSX

    expected = <<~JSX
      <div>
        <% stats.each do |item| %>
          <dd>foo</dd>
        <% end %>
      </div>
    JSX

    result = TailwindUi::Markup.new(code).result

    assert_equal expected, result.chomp
  end

  def test_ruby_code_ternary_with_null
    code = <<~JSX
      <div>
        {stat.unit ? <span>{stat.unit}</span> : null}
      </div>
    JSX

    expected = <<~JSX
      <div>
        <% if stat.unit %><span><%= stat.unit %></span><% end %>
      </div>
    JSX

    result = TailwindUi::Markup.new(code).result

    assert_equal expected, result.chomp
  end
end
