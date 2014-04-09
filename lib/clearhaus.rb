require "rubygems"

require "faraday"
require "json"

# General (Version, Utils and Erros)
require "clearhaus/version"
require "clearhaus/utils"
require "clearhaus/error"

# Http Client
require "clearhaus/http_client/auth_handler"
require "clearhaus/http_client/error_handler"
require "clearhaus/http_client/response"
require "clearhaus/http_client"

# API
require "clearhaus/api/card"
require "clearhaus/api/card_operations"
require "clearhaus/api/transaction_operations"


require "clearhaus/client"

module Clearhaus # :nodoc: all

  @endpoint = "https://gateway.clearhaus.com"
  @silent   = true

  class << self
    attr_accessor :endpoint, :silent, :api_key
    attr_reader :_httpc, :_links

    def httpc
      @_httpc = Clearhaus::HttpClient::Client.new unless @_httpc
      # Need to discover and cache @_links
      return @_httpc
    end
  end

end