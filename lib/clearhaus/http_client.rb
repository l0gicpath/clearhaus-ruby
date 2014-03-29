module Clearhaus # :nodoc: all

  module HttpClient

    class Client
      attr_accessor :options

      def initialize(api_key, options)
        @options = {
          :endpoint => "https://gateway.clearhaus.com",
          :user_agent => "clearhaus/ruby-#{ Clearhaus::VERSION } http://clearhaus.com",
          :silent => true
        }

        @options.update options

        @headers = {
          "user-agent" => @options[:user_agent]
        }

        if @options.has_key? :headers
          @headers.update Hash[@options[:headers].map { |k, v| [k.downcase, v] }]
          @options.delete :headers
        end

        @client = Faraday.new @options[:endpoint] do |conn|
          conn.use Clearhaus::HttpClient::AuthHandler, api_key
          conn.use Clearhaus::HttpClient::ErrorHandler unless @options[:silent]

          conn.adapter Faraday.default_adapter
        end
      end

      def get(path, params = {}, options = {})
        request path, nil, "get", options.merge({ :query => params })
      end

      def post(path, body = {}, options = {})
        request path, body, "post", options
      end

      # Handles both get and post requests, if it's a post request we change the request body accordingly
      def request(path, body, method, options)
        options = @options.merge options
        options[:headers] ||= {}
        options[:headers] = @headers.merge Hash[options[:headers].map{ |k, v| [k.downcase, v] }]
        options[:body] = body

        options = set_body options unless method == "get"

        response = create_request method, path, options
        Clearhaus::HttpClient::Response.new(response)
      end

      # Makes the actual request given a method, path and options
      def create_request(method, path, options)
        instance_eval <<-RUBY, __FILE__, __LINE__ + 1
          @client.#{method} path do |req|
            req.body = options[:body]
            req.headers.update options[:headers]
            req.params.update options[:query] if options[:query]
          end
        RUBY
      end

      # Set request body as POST form-data
      def set_body(options)
        options[:body] ||= {}
        options[:body] = Faraday::Utils::ParamsHash[options[:body]].to_query
        options[:headers]["content-type"] = "application/x-www-form-urlencoded"
        return options
      end
    end

  end
end