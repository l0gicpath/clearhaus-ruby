module Clearhaus

  module Error

    class Standard < ::StandardError; end

    class ClientError < Standard
      attr_reader :code

      def initialize(message, code)
        @code = code
        super message
      end
    end

    class MissingParamError < Standard
      def message
        "You've supplied missing params"
      end
    end

  end

end