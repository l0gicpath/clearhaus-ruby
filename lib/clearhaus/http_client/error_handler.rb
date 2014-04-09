module Clearhaus # :nodoc: all

  module HttpClient

    class ErrorHandler < Faraday::Middleware

      def initialize(app)
        super(app)
      end

      # Checks on the API response to see if Clearhaus has reported any errors
      # Raises a ClientError with the code and message received from Clearhaus
      def call(env)
        @app.call(env).on_complete do
          next if Clearhaus.silent
          status = JSON.parse(env[:body])['status']
          case status['code']
          when 40000..50100
            raise Clearhaus::Error::ClientError.new(status['code'], status['message'] || "")
          end
        end
      end

    end

  end

end