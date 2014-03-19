require 'spec_helper'


describe Clearhaus do

  before do
    @client = Clearhaus::Client.new(Mock.api_key)
  end

  it 'Should allow the authorization of a certain amount' do
    response = @client.authorize(
        :amount => 1, 
        :card => Mock.card,
        :currency => "EUR",
        :ip => "1.1.1.1",
        :text_on_statement => "authorization-0"
      )
    expect(response['status']['code']).to eq 20000
  end

  it 'Can tokenize card data returning a card token' do
    card_token = @client.tokenize(Mock.card)
    expect(card_token['status']['code']).to eq 20000
  end

  it 'Should allow the authorization of a certain amount using a card token' do
    card_token = @client.tokenize(Mock.card)
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