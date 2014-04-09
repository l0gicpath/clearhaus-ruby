require "base64"

module Clearhaus # :nodoc: all

  module HttpClient

    class AuthHandler < Faraday::Middleware

      def initialize(app)
        super(app)
      end

      def call(env)
        raise ArgumentError, "Missing an API key" unless Clearhaus.api_key
        env = basic_auth env
        @app.call(env)
      end

      # Clearhaus authenticates clients using basic authentication
      # Expects the API key to be used in place of a username and a blank password
      def basic_auth(env)
        auth = Base64.encode64 "#{Clearhaus.api_key}:"
        env[:request_headers]["Authorization"] = "Basic #{auth}"
        return env
      end

    end

  end

end