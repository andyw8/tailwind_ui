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
  end
end
