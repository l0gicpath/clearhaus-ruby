module Clearhaus # :nodoc:

  # Courtesy of http://stackoverflow.com/a/8380073 with minor refactoring to fit our case
  def self.symbolize hash
    Hash === hash ? 
      Hash[
        hash.map do |k, v| 
          [k.respond_to?(:to_sym) ? k.to_sym : k, symbolize(v)] 
        end 
      ] : hash
  end

end