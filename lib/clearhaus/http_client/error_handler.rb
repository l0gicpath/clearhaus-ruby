module Clearhaus

  module HttpClient

    class ErrorHandler < Faraday::Middleware

      def initialize(app)
        super(app)
      end

      def call(env)
        @app.call(env).on_complete do
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