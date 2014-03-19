module Clearhaus

  module Error

    class Standard < ::StandardError; end

    class ClientError < Standard
      attr_reader :code

      def initialize(error_code, message = "")
        @code = error_code
        errors = {
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
        super "#{ errors[error_code] } #{ message.capitalize }"
      end
    end

  end

end