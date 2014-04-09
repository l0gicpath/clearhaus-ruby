module Clearhaus #:nodoc:
  module Api #:nodoc:

    module CardOperations
      def token
        @params[:card_token]
      end

      def number
        "xxxx xxxx xxxx #{@params[:last4]}"
      end

      def brand
        @params[:scheme]
      end

      def charge(data)
        Clearhaus::Client.charge(data.update(:card => token))
      end
    end

  end
end