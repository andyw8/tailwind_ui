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

  def test_jsx_keyword_handling
    code = <<~JSX
      export default function Example() {
        return (
          <div className="foo bar" htmlFor="baz">
            Hello, world!
          </div>
        )
      }
    JSX

    expected = <<~JSX
      <div class="foo bar" for="baz">
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
      if compare_against_html(path)
        puts "MATCH: #{path}"
      else
        puts "NO MATCH"
      end
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

  def squish(s)
    s.gsub!(/\A[[:space:]]+/, "")
    s.gsub!(/[[:space:]]+\z/, "")
    s.gsub!(/[[:space:]]+/, " ")
    s
  end

  def compare_against_html(jsx_path)
    jsx = File.read(jsx_path)
    converted = TailwindUi::JsxToErb.new(jsx).full

    html_path = jsx_path.gsub("react", "html").gsub(".jsx", ".html")
    html = File.read(html_path)
    documents_equivalent?(converted, html)
  end

  private

  def documents_equivalent?(doc1, doc2)
    doc1 = Nokogiri::XML.fragment(doc1)
    doc2 = Nokogiri::XML.fragment(doc2)

    # Normalize both documents
    doc1.xpath("//text()").each { |node| node.content = node.content.strip }
    doc2.xpath("//text()").each { |node| node.content = node.content.strip }

    # Sort attributes for consistent comparison
    doc1.xpath("//*").each do |node|
      node.attributes.sort_by(&:name).each do |attr|
        node.set_attribute(attr.name, attr.value)
      end
    end
    doc2.xpath("//*").each do |node|
      node.attributes.sort_by(&:name).each do |attr|
        node.set_attribute(attr.name, attr.value)
      end
    end

    # Remove whitespace
    a = doc1.to_xml
    b = doc2.to_xml
    a.gsub(/\s+/, "") == b.gsub(/\s+/, "")
  end
end
