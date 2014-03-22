require "base64"

module Clearhaus # :nodoc: all

  module HttpClient

    class AuthHandler < Faraday::Middleware

      def initialize(app, api_key, options = {})
        @api_key = api_key
        super(app)
      end

      # Checks whether we were given an API key or not, raising an ArgumentError for a missing API key
      def call(env)
        if !@api_key.empty?
          env = basic_auth env
          @app.call(env)
        else
          raise ArgumentError, "Missing an API key"
        end
      end

      # Clearhaus authenticates clients using basic authentication
      # Expects the API key to be used in place of a username and a blank password
      def basic_auth(env)
        auth = Base64.encode64 "#{@api_key}:"
        env[:request_headers]["Authorization"] = "Basic #{auth}"
        return env
      end

    end

  end

end