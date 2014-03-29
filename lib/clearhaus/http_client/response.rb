module Clearhaus #:nodoc:

  module HttpClient #:nodoc:

    Status = Struct.new(:state, :code, :message)

    class Response

      attr_reader :body
      attr_reader :status

      
      def initialize(response)
        @body = symbolize( JSON.parse(response.body) ) #TODO: should probably handle exceptions here
        analyize

        define_states :approved?, :challenged?, :declined? do |state|
          @status.state =~ /#{state}/ ? true : false
        end
      end

      def [](key)
        @body[key]
      end



      private

      # Courtesy of http://stackoverflow.com/a/8380073 with minor refactoring to fit our case
      def symbolize hash
        Hash === hash ? 
          Hash[
            hash.map do |k, v| 
              [k.respond_to?(:to_sym) ? k.to_sym : k, symbolize(v)] 
            end 
          ] : hash
      end

      def analyize #:nodoc:
        case @body[:status][:code]
        when 20000
          @status = Status.new(:approved)
        when 20200
          @status = Status.new(:challenged)
        when 40000..50100
          @status = Status.new(:declined)
        end

        @status.code, @status.message = @body[:status][:code], @body[:status][:message] || ""
      end

      def define_states(*states, &block)
        states.each do |state|
          self.class.send(:define_method, state) do
            instance_exec state.to_s, &block
          end
        end
      end
    end

  end

end