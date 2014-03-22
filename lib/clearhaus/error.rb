module Clearhaus #:nodoc:

  module Error

    ##
    # A +ClientError+ is a +StandardError+ that's thrown when Clearhaus API reports a problem
    class ClientError < ::StandardError

      ##
      # Error code returned by Clearhaus API
      attr_reader :code

      ERRORS = {
        40000 => "General input error.",
        40101 => "Problem with card number.",
        40102 => "Problem with CSC.",
        40103 => "Card expired or invalid expire date.",
        40200 => "Declined by Firewall.",
        40201 => "Try again with 3D Secure.",
        40300 => "Problem with 3D Secure.",
        40400 => "Risk limit exceeded.",
        50000 => "Clearhaus error.",
        50100 => "General card problem."
      }

      def initialize(error_code, message = "")
        @code = error_code
        super "#{ ERRORS[error_code] } #{ message.capitalize }"
      end

    end

  end

end