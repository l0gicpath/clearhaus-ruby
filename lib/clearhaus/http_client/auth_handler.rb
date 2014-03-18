require "base64"

module Clearhaus

  module HttpClient

    class AuthHandler < Faraday::Middleware

      def initialize(app, api_key, options = {})
        @api_key = api_key
        super(app)
      end

      def call(env)
        if !@api_key.empty?
          env = basic_auth env
          @app.call(env)
        else
          raise Clearhaus::Error::MissingParamError.new
        end
      end

      def basic_auth(env)
        auth = Base64.encode64 "#{@api_key}:"
        env[:request_headers]["Authorization"] = "Basic #{auth}"
        return env
      end

    end

  end

end