clearhaus-ruby
==============

Ruby client library for Clearhaus transaction API.


Clearhaus transaction API
-------------------------

In the Clearhaus transaction API you can process payment card transactions; say,
move money from a credit card to a merchant account at Clearhaus (or the other
way around).

Have a look at `the API documentation <http://docs.gateway.clearhaus.com>`_.

Usage
=====

The Clearhaus ruby bindings directly maps to Clearhaus REST-API. This means the client
methods expect the same params that the REST-API expects and it will directly return
the JSON output from the REST-API.

In case of any problems reported by Clearhaus, a Clearhaus::Error::ClientError exception is raised.

To initialize a new instance of the client, provide it with an API key::

  @client = Clearhaus::Client.new("API-KEY")


Tokenize Credit Cards
---------------------

To tokenize a card, feed the credit card details to the **#tokenize** method::

  response = @client.tokenize(
      :number => 4111111111111111,
      :expire_month => 12,
      :expire_year => 2017,
      :csc => 123
    )
  token = response['card_token']

Charging Credit Cards
---------------------

There are two ways to charge a credit card, it can be done in one step using **#charge** or over two steps
using **#authorize** followed by a call to **#capture**

Charge a credit card in one step::

  response = @client.charge(
    :amount => 1000,
    :card_token => token,
    :currency => "EUR",
    :ip => "1.1.1.1" 
  )
  transaction_id = response['id']

Charge a credit card in two steps::

  response = @client.authorize(
    :amount => 1000,
    :card_token => token,
    :currency => "EUR",
    :ip => "1.1.1.1" 
  )
  response = @client.capture(:transaction_id => response['id'])

