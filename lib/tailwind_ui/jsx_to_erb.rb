require "erb"
require "nokogiri"
require "tailwind_ui/data"
require "tailwind_ui/markup"

module TailwindUi
  class Error < StandardError
  end

  class NotYetSupported < TailwindUi::Error
  end

  class UnconvertedBraces < TailwindUi::Error
  end

  class ClipPathNotYetSupported < TailwindUi::Error
  end

  class NeedsImports < TailwindUi::Error
  end

  class NeedsData < TailwindUi::Error
  end

  class ErbError < TailwindUi::Error
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

      if file_contents.lines.any? { _1.start_with?("import") }
        raise NeedsImports
      end

      # if file_contents.lines.any? { _1.start_with?("const") }
      #   raise NeedsData
      # end

      # unless file_contents.lines.first.start_with?("export default function")
      #   raise NotYetSupported
      # end

      if file_contents.include?("clipPath")
        raise ClipPathNotYetSupported
      end

      @file_contents = file_contents
    end

    def full
      tags = @file_contents.match(/(?<tags> *<.*>)/m)[:tags]
      markup = Markup.new(tags)
      result = markup.result
      check_for_missed_camel_case_tags!(result)
      raise UnconvertedBraces if result.include?("{") || result.include?("}")

      # Parse the ERB to ensure it's valid
      begin
        $VERBOSE = nil
        ERB.new(result).result
        $VERBOSE = 1
      rescue Exception => e # rubocop:disable Lint/RescueException
        raise ErbError, e.message
      end

      result
    end

    def data
      name, values = @file_contents.match(/const (\w+) = (\[.*\])/m)[1, 2]
      Data.new(name, values).to_erb
    end

    private

    CAMEL_CASE = /^[a-zA-Z]+([A-Z][a-z]+)+$/

    def check_for_missed_camel_case_tags!(str)
      # Need to specify XML here to avoid Nokgiri downcasing automatically
      doc = Nokogiri::XML.fragment(str)

      doc.traverse do |node|
        node.attributes.each do |name, value|
          raise TailwindUi::Error, "found camelcase: #{name}" if name.match?(CAMEL_CASE)
        end
      end
    end
  end
end
