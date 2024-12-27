PATH = "/Users/andy/src/github.com/andyw8/tailwindui/react/components"

require "tailwind_ui/jsx_to_erb"

class Source
  def initialize(path)
    @path = path
  end

  def content
    @content ||= File.read(@path)
  end

  def lines
    content.lines
  end

  def trivial?
    content.lines.first.start_with?("export default function")
  end
end

total = 0
trivial = 0
failed = []

Dir.glob("#{PATH}/**/*.jsx").each do |path|
  source = Source.new(path)
  puts path
  total += 1
  next unless source.trivial?

  trivial += 1

  begin
    TailwindUi::JsxToErb.from_path(path).full
  rescue StandardError
    failed << path
  end

  puts
end

puts "trivial: #{trivial}"
puts "total: #{total}"
puts "failed: #{failed}"
