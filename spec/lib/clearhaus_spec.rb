require 'spec_helper'


describe Clearhaus do

  before do
    @client = Clearhaus::Client.new(Mock.api_key)
  end

  it "Should allow the authorization of a certain amount" do
    response = @client.authorize(
        :amount => 1, 
        :card => Mock.card,
        :currency => "EUR",
        :ip => "1.1.1.1",
        :text_on_statement => "authorization-0"
      )
    
    expect(response['status']['code']).to eq 20000
  end

  it "Can tokenize card data returning a card token" do
    card_token = @client.tokenize(Mock.card)
    expect(card_token['status']['code']).to eq 20000
  end

  it "Should allow the authorization of a certain amount using a card token" do
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

  it "Should allow an authorized transaction to be captured" do
    response = @client.authorize(
        :amount => 1,
        :card => Mock.card,
        :currency => "EUR",
        :ip => "1.1.1.1"
      )

    response = @client.capture(:transaction_id => response['id'])
    expect(response['status']['code']).to eq 20000
  end

  it "Should allow attempts to capture a specific amount of a previously authorized transaction" do
    response = @client.authorize(
        :amount => 10,
        :card => Mock.card,
        :currency => "EUR",
        :ip => "1.1.1.1"
      )

    response = @client.capture(:amount => 5, :transaction_id => response['id'])
    expect(response['status']['code']).to eq 20000
  end

  it "Should reject attempts to capture a transaction that doesn't exist (hasn't been authorized yet)" do
    expect{
      
      @client.capture( :transaction_id => "unknown-transaction-id" )

    }.to raise_error(Clearhaus::Error::ClientError)

  end

  it "Should allow an authorized transaction that hasn't been captured yet to be voided" do
    response = @client.authorize(
        :amount => 1,
        :card => Mock.card,
        :currency => "EUR",
        :ip => "1.1.1.1"
      )

    response = @client.void(:transaction_id => response['id'])
    expect(response['status']['code']).to eq 20000
  end

  it "Should fail when trying to void a transaction that has been captured" do
    pending("the addition of Clearhaus::Client#charge method")
  end
end