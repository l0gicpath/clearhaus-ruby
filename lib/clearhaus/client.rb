module Clearhaus # :nodoc:

  ##
  # Provides direct mapping to clearhaus API. To start using it, it must be initialized with a clearhaus API
  # key and an optional list of params (See: Clearhaus::Client#initialize for more details)
  class Client

    ##
    # Create a new instance of the client with a clearhaus API key
    # params:
    # +api_key+:: clearhaus api key 
    # +options+:: an optional hash for setting the :endpoint of the api or the :user_agent of all client requests
    def initialize(api_key, options = {})
      @httpc = Clearhaus::HttpClient::Client.new api_key, options
    end

    ##
    # Given credit card details, it generates a token for this credit card
    # Returns the same JSON response returned by the API
    # Example:
    #   tokenize(
    #       :number => 4111111111111111,
    #       :expire_month => 12,
    #       :expire_year  => 2017,
    #       :csc => 123
    #     )
    def tokenize(card)
      payload = {
        "card[number]" => card[:number],
        "card[expire_month]" => card[:expire_month],
        "card[expire_year]" => card[:expire_year],
        "card[csc]" => card[:csc]
      }
      @httpc.post("/cards", payload)
    end

    ##
    # Preforms an authorize and then a capture on the given credit card information, or credit card token and
    # expects the same params given to the API
    # See: Clearhaus::Client#authorize
    def charge(data)
      response = authorize(data)
      capture(:transaction_id => response[:id])
    end

    ##
    # Authorizes a new transaction, directly mapping the API and expects the same params. Also returns the same
    # JSON returned by the API
    # Example:
    #   card = {
    #     :number => 4111111111111111,
    #     :expire_month => 12,
    #     :expire_year  => 2017,
    #     :csc => 123
    #   }
    #   authorize(
    #      :amount => 1000, 
    #      :card => card,
    #      :currency => "EUR",
    #      :ip => "1.1.1.1",
    #    )
    def authorize(data)
      payload = {
        "amount" => data.delete(:amount)
      }

      if data[:card_token]
        payload.merge!("card_token" => data.delete(:card_token))
      else
        payload.merge!({
            "card[number]" => data[:card][:number],
            "card[expire_month]" => data[:card][:expire_month],
            "card[expire_year]" => data[:card][:expire_year],
            "card[csc]" => data[:card][:csc]
          })
        data.delete(:card)
      end

      payload.merge!(Hash[data.map { |k, v| [k.downcase.to_s, v] }])
      @httpc.post("/authorizations", payload)
    end

    ##
    # Captures an already authorized transaction, directly mapping the API and expects the same params. Also returns
    # the same JSON returned by the API
    # Example:
    #   capture( :transaction_id => "ID Of Authorized Transaction" )
    def capture(data)
      payload = { "amount" => data[:amount] } if data[:amount]

      @httpc.post("/authorizations/#{ data[:transaction_id] }/captures", payload || {})
    end

    ##
    # Voids an authorized transaction, directly mapping the API and expects the same params. Also returns the same JSON
    # returned by the API
    # Example:
    #   void( :transaction_id => "ID Of Authorized Transaction" )
    def void(data)
      @httpc.post("/authorizations/#{ data[:transaction_id] }/voids")
    end

    ##
    # Refunds a captured/charged transaction, directly mapping the API and expects the same params. Also returns the same JSON
    # returned by the API
    # Example:
    #   refund( :transaction_id => "ID Of Authorized Transaction" )
    def refund(data)
      payload = { "amount" => data[:amount] } if data[:amount]

      @httpc.post("/captures/#{ data[:transaction_id] }/refunds", payload || {})
    end

  end

end