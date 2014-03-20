module Clearhaus

  class Client

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

    def charge(data)
      response = authorize(data)
      capture(:transaction_id => response['id'])
    end

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

    def capture(data)
      payload = { "amount" => data[:amount] } if data[:amount]

      @httpc.post("/authorizations/#{ data[:transaction_id] }/captures", payload || {})
    end

    def void(data)
      @httpc.post("/authorizations/#{ data[:transaction_id] }/voids")
    end

    def refund(data)
      payload = { "amount" => data[:amount] } if data[:amount]

      @httpc.post("/captures/#{ data[:transaction_id] }/refunds", payload || {})
    end

  end

end