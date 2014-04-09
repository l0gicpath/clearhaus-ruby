module Clearhaus #:nodoc:
  module Api #:nodoc:

    module TransactionOperations
      def id
        @params[:id]
      end

      def capture(amount = nil)
        Clearhaus::Client.capture(id, amount: amount)
      end

      def void
        Clearhaus::Client.void(id)
      end

      def refund(amount = nil)
        Clearhaus::Client.refund(id, amount: amount)
      end

    end

  end
end