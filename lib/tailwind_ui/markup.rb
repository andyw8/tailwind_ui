module TailwindUi
  class Markup
    def initialize(tags)
      @tags = tags
    end

    def result
      result = without_indentation
      result = handle_ruby_code(result)
      result = handle_style_attributes(result)
      result = convert_camelcase_attributes(result)
      result = handle_jsx_comments(result)

      result = handle_brace_attributes(result)
      result = handle_inner_braces(result)
      check_for_missed_braces!(result)
      result
    end

    private

    attr_reader :tags

    def check_for_missed_braces!(result)
      # binding.irb
      if result.include?("{") || result.include?("}")
        raise UnconvertedBraces
      end
    end

    def handle_ruby_code(markup)
      markup
        .gsub(/{(\w+).map\(\((\w+)\) => \(/, '<% \1.each do |\2| %>')
        .gsub(/{(\w+).each\(\((\w+)\) => \(/, '<% \1.each do |\2| %>')
        .gsub("))}", "<% end %>")
        .gsub(/{(.*) \? (.*) : null}/, '<% if \1 %>\2<% end %>')
      # binding.irb
    end

    def convert_camelcase_attributes(markup)
      result = markup
      {
        autoComplete: "autocomplete",
        className: "class",
        clipRule: "clip-rule",
        colSpan: "col-span",
        dateTime: "datetime",
        defaultValue: "value",
        fillOpacity: "fill-opacity",
        fillRule: "fill-rule",
        gradientTransform: "gradient-transform",
        gradientUnits: "gradient-units",
        htmlFor: "for",
        preserveAspectRatio: "preserve-aspect-ratio",
        stopColor: "stop-color",
        stopOpacity: "stop-opacity",
        strokeLinecap: "stroke-linecap",
        strokeLinejoin: "stroke-linejoin",
        strokeWidth: "stroke-width",
        vectorEffect: "vector-effect",
        viewBox: "view-box"
      }.each do |(camel_case, normal)|
        result = result.gsub("#{camel_case}=", "#{normal}=")
      end
      result
    end

    def handle_brace_attributes(markup)
      markup
        .gsub(/(\w+)=\{(\d+)}/m, '\1="\2"')
    end

    def without_indentation
      indentation_level = tags.index("<")
      tags.lines.map do |line|
        line[indentation_level..]
      end.join + "\n"
    end

    def handle_style_attributes(markup)
      markup.gsub(/style={{ (.*) }}/, 'style="\1"')
    end

    def handle_jsx_comments(markup)
      markup
        .gsub("{/*", "<%#")
        .gsub("*/}", "%>")
    end

    # should add a test
    def handle_inner_braces(markup)
      markup.gsub("{", "<%= ").gsub("}", " %>")
    end
  end
end
