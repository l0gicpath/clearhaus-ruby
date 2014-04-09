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

  module ExtractPayload

    module ClassMethods
      def from_hash(hash: {}, wrapwith: "")
        hash.map { |k, v| 
            v.is_a?(Hash) ? from_hash(hash: v, wrapwith: k) : 
              wrapwith.empty? ? {"#{k}" => v} : {"#{wrapwith}[#{k}]" => v}
          }.flatten.reduce({}, :merge)
      end

      def payload_from_hash(payload: {}, hash: {})
        payload.merge!( from_hash(hash: hash) )
      end
    end



    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end
  end

end