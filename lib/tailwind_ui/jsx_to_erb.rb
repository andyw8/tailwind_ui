module TailwindUi
  class Error < StandardError
  end

  class JsxToErb
    def self.from_path(path)
      file_contents = File.read(path)
      new(file_contents)
    rescue => e
      raise Error, e.message
    end

    def initialize(file_contents)
      @file_contents = file_contents
    end

    def full
      tags = @file_contents.match(/(?<tags> *<.*>)/m)[:tags]
      without_indentation(tags)
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
