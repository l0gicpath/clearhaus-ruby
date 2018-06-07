# Clearhaus-Ruby

[![Maintainability](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/maintainability)](https://codeclimate.com/github/l0gicpath/clearhaus-ruby)

Ruby client library for Clearhaus transaction API.

Clearhaus transaction API allows the processing of payments on credit cards, either moving money from a credit card to a merchant account at Clearhaus or the other way around.

[API documentations and other language bindings](http://docs.gateway.clearhaus.com)

## Usage

The ruby client will raise an ArgumentError exception if it was used before setting an API key.

### Setting API key

```ruby
Clearhaus.api_key = "API-key"
```

### Charge credit card

```ruby
card = {
  :number => 4111111111111111,
  :expire_month => 12,
  :expire_year => 2017,
  :csc => 123
}

transaction = Clearhaus::Client.charge(
    :amount => 1,
    :card => card,
    :currency => "EUR",
    :ip => "1.1.1.1" 
  )

# Check transaction status
transaction.approved?
transaction.declined?
transaction.challenged?
```

### Tokenize a card

```ruby
cc = {
  :number => 4111111111111111,
  :expire_month => 12,
  :expire_year => 2017,
  :csc => 123
}

card = Clearhaus::Client.tokenize(cc)
card.token # returns token
```

### Charge credit card using a card token

```ruby
cc = {
  :number => 4111111111111111,
  :expire_month => 12,
  :expire_year => 2017,
  :csc => 123
}

card = Clearhaus::Client.tokenize(cc)

transaction = Clearhaus::Client.charge(
    :amount => 1,
    :card => card.token,
    :currency => "EUR",
    :ip => "1.1.1.1" 
  )

# Or invoke charge directly on the response object returned from tokenize (Which is decorated with CardOperations)

transaction = card.charge(
    :amount => 1,
    :currency => "EUR",
    :ip => "1.1.1.1" 
  )
```

### Authorize an amount

```ruby
transaction = Clearhaus::Client.authorize(
    :amount             => 100,
    :card               => card,
    :currency           => "EUR",
    :ip                 => "1.1.1.1",
  )
```

### Capture an authorized transaction

```ruby
transaction = Clearhaus::Client.authorize(
    :amount             => 1,
    :card               => card,
    :currency           => "EUR",
    :ip                 => "1.1.1.1",
  )
Clearhaus::Client.capture(transaction.id)

# Or invoke capture directly on the response object returned from authorize

transaction.capture
```
 
## Error Reporting

Errors are by default supressed and to check whether an operation was a success or not, use approved? declined? challenged? methods.

Response objects also expose response_code and response_message. If explicit error reporting is required and code should break on errors then set Clearhaus.silent to false

```ruby
Clearhaus.silent = false
```

After that, any error reported by Clearhaus API will raise a Clearhaus::Error::ClientError exception with the given error code
and message as reported by Clearhaus API.
