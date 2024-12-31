# https://winfrednadeau.com/2012/03/24/unobtrusive-dot-hash-access-for-ruby/

class Hash
  class NoKeyOrMethodError < NoMethodError; end

  def method_missing(method, *args)
    m = method.to_s
    string_key = m.gsub(/=$/, "")
    sym_key = string_key.to_sym
    if has_key? string_key
      /=$/.match?(m) ? send(:"[#{string_key}]=", *args) : self[string_key]
    elsif has_key? sym_key
      /=$/.match?(m) ? send(:"[#{sym_key}]=", *args) : self[sym_key]
    else
      # In the original implementation, this will raise NoKeyOrMethodError
      # I changed it to behave more like JavaScript.
      nil
    end
  end
end
