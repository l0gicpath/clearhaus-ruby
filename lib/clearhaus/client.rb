## Maps the api
module Clearhaus

  class Client

    # Initializes a new client with the given api_key and options.
    # The http client will be responsible for figuring out whether we were given an api key or not then
    # throw a missing api key error.
    def initialize(api_key, options = {})
      @httpc = Clearhaus::HttpClient::Client.new api_key, options
    end

    def tokenize(card)
      payload = {
        "card[number]" => card[:number],
        "card[expire_month]" => card[:expire_month],
        "card[expire_year]" => card[:expire_year],
        "card[csc]" => card[:csc]
      }
      @httpc.post("/cards", payload)
    end

    # Authorizes an amount against the given card
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

    # Capture all or part of the transaction's amount
    def capture(data)
      payload = { "amount" => data[:amount] } if data[:amount]

      @httpc.post("/authorizations/#{ data[:transaction_id] }/captures", payload || {})
    end

    # Undo an authorization
    def void(data)
      @httpc.post("/authorizations/#{ data[:transaction_id] }/voids")
    end

    # Refund a transaction
    def refund(data)
      @httpc.post("/authorizations/#{ data[:transaction_id] }/refunds")
    end

  end

end