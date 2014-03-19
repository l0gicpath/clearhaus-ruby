require 'spec_helper'


describe Clearhaus do

  before do
    @client = Clearhaus::Client.new("8ce11e76-6aa5-4619-bbe1-e8b4900b6ed9")
  end

  it 'Should allow the authorization of a certain amount' do
    card = {
        :number => 4111111111111111,
        :expire_month => 12,
        :expire_year => 2017,
        :csc => 123
      }
    response = @client.authorize(
        :amount => 1, 
        :card => card, 
        :currency => "EUR",
        :ip => "1.1.1.1",
        :text_on_statement => "authorization-0"
      )
    expect(response['status']['code']).to eq 20000
  end

  it 'Can tokenize card data returning a card token' do
    card_token = @client.tokenize(
        :number => 4111111111111111,
        :expire_month => 12,
        :expire_year => 2017,
        :csc => 123
      )
    expect(card_token['status']['code']).to eq 20000
  end

  it 'Should allow the authorization of a certain amount using a card token' do
    card = {
        :number => 4111111111111111,
        :expire_month => 12,
        :expire_year => 2017,
        :csc => 123
      }
    card_token = @client.tokenize(card)
    response = @client.authorize(
      :amount => 1, 
      :card_token => card_token['card_token'],
      :currency => "EUR",
      :ip => "1.1.1.1",
      :text_on_statement => "authorization-0"   
    )
    expect(response['status']['code']).to eq 20000
  end
end