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
    def authorize(options = {})
      payload = {
        "amount" => options.delete(:amount)
      }

      if options[:card_token]
        payload.merge!("card_token" => options.delete(:card_token))
      else
        payload.merge!({
            "card[number]" => options[:card][:number],
            "card[expire_month]" => options[:card][:expire_month],
            "card[expire_year]" => options[:card][:expire_year],
            "card[csc]" => options[:card][:csc]
          })
        options.delete(:card)
      end

      payload.merge!(Hash[options.map { |k, v| [k.downcase.to_s, v] }])
      @httpc.post("/authorizations", payload)
    end

    # Capture all or part of the transaction's amount
    def capture(amount, transaction_id)
      @httpc.post("/authorizations/#{ transaction_id }/captures", { "amount" => amount })
    end

    # Undo an authorization
    def void(transaction_id)
      @httpc.post("/authorizations/#{ transaction_id }/void")
    end

    # Refund a transaction
    def refund(transaction_id)
      @httpc.post("/authorizations/#{ transaction_id }/refund")
    end

  end

end