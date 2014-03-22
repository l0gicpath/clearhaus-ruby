# Courtesy of http://speakmy.name/2011/05/29/simple-configuration-for-ruby-apps/
# With minor refactoring and some additions to fit our case
module Mock # :nodoc:
  # again - it's a singleton, thus implemented as a self-extended module
  extend self

  @_mockdata = {}
  attr_reader :_mockdata

  def load!(filename, options = {})
    newsets = symbolize( YAML::load_file(filename) )
    newsets = newsets[options[:env].to_sym] if \
                                               options[:env] && \
                                               newsets[options[:env].to_sym]
    deep_merge!(@_mockdata, newsets)
  end

  # Courtesy of http://stackoverflow.com/a/8380073 with minor refactoring to fit our case
  def symbolize hash
    Hash === hash ? 
      Hash[
        hash.map do |k, v| 
          [k.respond_to?(:to_sym) ? k.to_sym : k, symbolize(v)] 
        end 
      ] : hash
  end

  # Deep merging of hashes
  # deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
  def deep_merge!(target, data)
    merger = proc{|key, v1, v2|
      Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    target.merge! data, &merger
  end

  def method_missing(name, *args, &block)
    @_mockdata[name.to_sym] ||
    fail(NoMethodError, "unknown configuration root #{name}", caller)
  end

end