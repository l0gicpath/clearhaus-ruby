require 'sinatra/base'

class FakeClearhaus < Sinatra::Base # :nodoc:

  # Authorize a new transaction
  post '/authorizations' do
    json_response 200, "authorized"
  end

  # Capture a transaction
  post '/authorizations/:id/captures' do
  end

  # Void a transaction
  post '/authorizations/:id/voids' do
  end

  # Refund a transaction
  post '/captures/:id/refunds' do
  end

  # Tokenize a card
  post '/cards' do
  end

  private

  def json_response(response_code, type)
    status response_code
    content_type "application/vnd.clearhaus-gateway.hal+json; version=0.1.0; charset=utf-8"
    File.open("#{ File.dirname(__FILE__) }/fixtures/#{ type }.json", "rb").read
  end

end