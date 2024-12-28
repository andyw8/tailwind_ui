require "erb"

module TailwindUi
  class Error < StandardError
  end

  class NotYetSupported < TailwindUi::Error
  end

  class UnconvertedBraces < TailwindUi::Error
  end

  class ClipPathNotYetSupported < TailwindUi::Error
  end

  class Special < TailwindUi::Error
  end

  class JsxToErb
    def self.from_path(path)
      file_contents = File.read(path)
      new(file_contents)
    end

    def initialize(file_contents)
      if file_contents.include?("This example requires updating your template")
        raise Special
      end

      unless file_contents.lines.first.start_with?("export default function")
        raise NotYetSupported
      end

      if file_contents.include?("clipPath")
        raise ClipPathNotYetSupported
      end

      @file_contents = file_contents
    end

    def full
      tags = @file_contents.match(/(?<tags> *<.*>)/m)[:tags]
      result = without_indentation(tags)
      result = handle_style_attributes(result)
      result = with_class_name_conversion(result)
      result = handle_jsx_comments(result)
      result = handle_brace_attributes(result)
      result = handle_inner_braces(result)
      raise UnconvertedBraces if result.include?("{") || result.include?("}")

      ERB.new(result).result

      result
    end

    private

    def handle_jsx_comments(markup)
      markup
        .gsub("{/*", "<%#")
        .gsub("*/}", "%>")
    end

    def handle_brace_attributes(markup)
      markup
        .gsub(/(\w+)=\{(\d+)}/m, '\1="\2"')
    end

    def handle_style_attributes(markup)
      markup.gsub(/style={{ (.*) }}/, 'style="\1"')
    end

    def handle_inner_braces(markup)
      markup.gsub("{", "<%= ").gsub("}", " %>")
    end

    def with_class_name_conversion(markup)
      markup.gsub(/className="([^"]+)"/, 'class="\1"')
    end

    def without_indentation(tags)
      indentation_level = tags.index("<")
      tags.lines.map do |line|
        line[indentation_level..]
      end.join + "\n"
    end
  end
end
