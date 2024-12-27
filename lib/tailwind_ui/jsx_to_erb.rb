require "erb"

module TailwindUi
  class Error < StandardError
  end

  class NotYetSupported < TailwindUi::Error
  end

  class JsxToErb
    def self.from_path(path)
      file_contents = File.read(path)
      new(file_contents)
    end

    def initialize(file_contents)
      @file_contents = file_contents
      unless file_contents.lines.first.start_with?("export default function")
        raise NotYetSupported
      end
    end

    def full
      tags = @file_contents.match(/(?<tags> *<.*>)/m)[:tags]
      result = without_indentation(tags)
      ERB.new(result).result
      result
    end

    private

    def without_indentation(tags)
      indentation_level = tags.index("<")
      tags.lines.map do |line|
        line[indentation_level..]
      end.join + "\n"
    end
  end
end
