require "json"

module TailwindUi
  class JsxToErb
    def self.from_path(path)
      file_contents = File.read(path)
      new(file_contents)
    end

    def initialize(file_contents)
      @file_contents = file_contents
    end

    def js_match
      @file_contents.match(/const (\w+) = (\[.*\])/m)
    end

    def array_ruby
      arr_raw = js_match[2]
      arr_raw.gsub!("null", "nil")
      arr_raw.gsub!(%r{// More .*\.\.\.}, " # More ...") if arr_raw.include?("// More")

      eval arr_raw
    end

    def full
      html # need to call first due to order dependency
      result = "<% #{data} %>"
      result += "\n\n\n"
      result += html
    end

    def html
      # probably better: https://gemini.google.com/app/aac8b4e213a6e06a

      template_body_original = file_contents.match(/return \(\n(.*>)/m)[1]

      template_body = convert_camelcase(template_body_original)

      # Nokogiri tries to 'fix' the HTML, so we need to undo that
      template_body.gsub!("&lt;", "<")
      template_body.gsub!("&gt;", ">")

      @plural = js_match[1]

      singular = template_body.match(/#{plural}\.map\(\((.*)\)/)[1]

      convert_to_ruby_hash!(file_contents, template_body)

      template_body.sub!("const people = [", "people = [")
      template_body.sub!("{people.map((person) => (", "<% people.each do |person| %>")
      template_body.sub!("{person.lastSeen ? (", "<% if person.lastSeen %>")
      template_body.sub!(") : (", "<% else %>")
      template_body.sub!(")}", "<% end %>")
      template_body.sub!("))}", "<% end %>")

      template_body.lines.map { _1.gsub(/^    /, "") }.join
      # raise "braces remaining" if final.include?("{") || final.include?("}")
    end

    def data
      "#{plural} = #{JSON.pretty_generate(array_ruby)}"
    end

    private

    attr_reader :file_contents, :plural

    def convert_to_ruby_hash!(file_contents, template_body)
      file_contents.scan(/(\{.*\})/).each do |match|
        # convert JS . syntax to Ruby hash symbol
        without_braces = match[0][1..-2]
        with_symbol_syntax = without_braces.split(".").join("][:").sub("]", "") + "]"
        replacement = "<%= " + with_symbol_syntax + " %>"
        template_body.gsub!(match[0], replacement)
      end
    end

    def convert_camelcase(str)
      doc = Nokogiri::HTML.fragment(str) do |config|
        config.noblanks.noent
      end

      doc.traverse do |node|
        if node.inner_html.start_with?("{") && node.inner_html.end_with?("}") && node.inner_html.include?("lastSeen")
          node.inner_html = node.inner_html.gsub("{", "<%= ")
          node.inner_html = node.inner_html.gsub("}", " %>")
        end
        node.attributes.each do |name, value|
          next unless value.value.start_with?("{")

          erb = node.attributes[name].value.gsub("{", "<%= ").gsub("}", " %>")
          node.set_attribute(name, erb)
        end
        if node.attributes["classname"]
          # Handle divs with class names
          class_name = node.attributes["classname"].value
          node.remove_attribute("classname")
          # node.name = "div"
          node.set_attribute("class", class_name)
          # binding.irb
          # elsif node.name == "input"
          #   # Handle input types
          #   input_type = node.attributes["type"].value
          #   node.name = input_type
          #   node.attributes.delete("type")
          # elsif node.name == "img"
          #   # Handle image source
          #   node.attributes["src"] = "<%= image_path('#{node.attributes["src"].value}') %>"
          # elsif node.name.start_with?("h")
          #   # Handle heading tags (h1, h2, etc.)
          #   node.name = "h#{node.name[1..-1]}"
        end

        # Remove unnecessary attributes
        # node.attributes.delete("key")
      end

      # 3. Convert Nokogiri document to ERB string
      # erb_code = doc.to_html.gsub(%r{</?([a-z0-9]+)>}, '<%\= content_tag(\1')
      # erb_code.gsub(/>/, ", &nil) %>")
      doc.to_xml
    end
  end
end
