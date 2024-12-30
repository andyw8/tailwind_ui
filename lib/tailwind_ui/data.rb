module TailwindUi
  class Data
    def initialize(name, values)
      @name = name
      @values = values
    end

    def to_erb
      "<% #{@name} = #{values_without_comments} %>\n"
    end

    def values_without_comments
      @values.gsub(%r{// More .*\.\.\.}, " # More #{@name}...")
    end
  end
end
