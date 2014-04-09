module Clearhaus # :nodoc:

  ##
  # Provides direct mapping to clearhaus API. To start using it, it must be initialized with a clearhaus API
  # key and an optional list of params (See: Clearhaus::Client#initialize for more details)
  class Client
    extend SingleForwardable
    include PayloadExtractor

    def_delegator :Clearhaus, :httpc

    class << self

      ##
      # Tokenize will take a card hash with the card details and tokenizes this returning
      # a Response object decorated with CardOperations
      # Card hash is expected to be in the following format:
      #   {
      #     :number => 4111111111111111,
      #     :expire_year => 2017,
      #     :expire_month => 12,
      #     :csc => 123
      #   }
      # Order of keys is irrelevant
      #
      # params:
      # +card+:: card hash containing credit card details as outlined in the example above
      def tokenize(card)
        payload = from_hash(hash: card, wrapwith: "card")

        response = httpc.post("/cards", payload)
        response.extend(Clearhaus::Api::CardOperations)
      end

      ##
      # Authorize will generate an authorization transaction, validating whether a +card+ has enough funds for
      # a purchase or not, if so it'll reserve +amount+ until it's captured
      # Returns a Response object decorated with TransactionOperations
      #
      # params:
      # +data+:: the required params to generate an authorization transaction. Expected values are as follows:
      #   :card => A card token or a card hash containing credit card details
      #   :amount => The amount to request an authorization for
      #   :ip => The IP address of the card holder
      #   :currency => The currency +amount+ is in
      #   :recurring => (Optional) Set to true if this is a recurring transaction
      #   :text_on_statement => (Optional) Text that'll be placed on the card holder's statement
      def authorize(data)
        payload = {}
        payload["card_token"] = data.delete(:card) if data[:card].is_a? String
        payload_from_hash(payload: payload, hash: data)

        response = httpc.post("/authorizations", payload)
        response.extend(Clearhaus::Api::TransactionOperations)
      end

      ##
      # Capture is intended to be used after a transaction has been authorized in order to transfer the funds
      # to the merchant. Capture can also be used to partially capture an amount of a transaction.
      # Returns a Response object decorated with TransactionOperations
      #
      # params:
      # +transaction_id+:: ID of a transaction that has been authorized
      # +amount+:: (Optional) If given, this will allow the capture of only a part of the whole transaction amount
      def capture(transaction_id, amount: nil)
        payload = { "amount" => amount } if amount

        response = httpc.post("/authorizations/#{ transaction_id }/captures", payload || {})
        response.extend(Clearhaus::Api::TransactionOperations)
      end

      ##
      # Void a transaction that was previously authorized but hasn't been captured yet. It returns a Response
      # object decorated with TransactionOperations
      # 
      # params:
      # +transaction_id+:: ID of a transaction that has been authorized
      def void(transaction_id)
        response = post("/authorizations/#{ transaction_id }/voids")
        response.extend(Clearhaus::Api::TransactionOperations)
      end

      ##
      # Refund a transaction that has been already captured. Can also be used for partial refunds if an amount
      # was passed to it.
      # Returns a Response decorated with TransactionOperations
      #
      # params:
      # +transaction_id+:: ID of a transaction that has already been captured
      # +amount+:: (Optional) If given, this will allow partial refund
      def refund(transaction_id, amount: nil)
        payload = { "amount" => amount } if amount

        response = httpc.post("/captures/#{ transaction_id }/refunds", payload || {})
        response.extend(Clearhaus::Api::TransactionOperations)
      end

      ##
      # Payout to a card holder
      #
      # params:
      # +data+:: the required params to generate an authorization transaction. Expected values are as follows:
      #   :card_token => A card token referring to the card that will be credited. See #tokenize
      #   :amount => The amount to payout
      #   :currency => The currency +amount+ is in
      #   :text_on_statement => (Optional) Text that'll be placed on the card holder's statement
      def credit(data)
        payload = from_hash(hash: data)
        httpc.post("/credits", payload)
      end

      ##
      # Charge will do an #authorize and #capture in one step, if the authorization returns a challenged or declined
      # response, it will get returned right away and wont perform a capture.
      # If authorization was a success, it will perform a capture.
      #
      # Always returns a Response object decorated with TransactionOperations
      #
      # params:
      # +data+:: Expects to receive the same params as #authorize
      def charge(data)
        response = authorize(data)
        return response.extend(Clearhaus::Api::TransactionOperations) unless response.approved?

        response = capture(response[:id])
        response.extend(Clearhaus::Api::TransactionOperations)
      end
    end

  end
end