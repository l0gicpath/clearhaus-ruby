module Clearhaus #:nodoc:

  module HttpClient #:nodoc:

    Status = Struct.new(:state, :code, :message)

    class Response
      extend Forwardable
      def_delegator :@status, :state, :status
      def_delegator :@status, :code, :response_code
      def_delegator :@status, :message, :response_message
      
      def initialize(response)
        parsed_body = response.body.is_a?(String) ? JSON.parse(response.body) : response.body
        @params = Clearhaus.symbolize( parsed_body )
        analyize

        define_states :approved?, :challenged?, :declined? do |state|
          @status.state =~ /#{state}/ ? true : false
        end
      end

      def [](key)
        @params[key]
      end

      private
      def analyize
        case @params[:status][:code]
        when 20000
          @status = Status.new(:approved)
        when 20200
          @status = Status.new(:challenged)
        when 40000..50100
          @status = Status.new(:declined)
        end

        @status.code, @status.message = @params[:status][:code], @params[:status][:message] || ""
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