require 'spec_helper'


describe Clearhaus do

  before(:all) do
    Clearhaus.api_key = Mock.api_key
  end

  it "Should allow the authorization of a certain amount" do
    transaction = Clearhaus::Client.authorize(
        :amount             => 1,
        :card               => Mock.card,
        :currency           => "EUR",
        :ip                 => "1.1.1.1",
        :text_on_statement  => "auth-all-params",
        :recurring          => true
      )

    expect(transaction.approved?).to be_true
    expect(transaction.status).to eq(:approved)
    expect(transaction.response_code).to eq(20000)
    expect(transaction.declined?).to be_false
  end

  it "Should allow authorization if we only include the non-optional params" do
    transaction = Clearhaus::Client.authorize(
        :amount             => 1,
        :card               => Mock.card,
        :currency           => "EUR",
        :ip                 => "1.1.1.1",
      )

    expect(transaction.approved?).to be_true
  end

  it "Can tokenize card data returning a card token" do
    card = Clearhaus::Client.tokenize(Mock.card)
    expect(card.approved?).to be_true
  end

  it "Should allow authorization with a given card token" do
    card = Clearhaus::Client.tokenize(Mock.card)
    transaction = Clearhaus::Client.authorize(
        :amount             => 1,
        :card               => card.token,
        :currency           => "EUR",
        :ip                 => "1.1.1.1",
      )
    expect(transaction.approved?).to be_true
  end

  it "Should allow an authorized transaction to be captured" do
    transaction = Clearhaus::Client.authorize(
        :amount             => 1,
        :card               => Mock.card,
        :currency           => "EUR",
        :ip                 => "1.1.1.1",
      )

    transaction = Clearhaus::Client.capture(transaction.id)
    expect(transaction.approved?).to be_true
  end

  it "Should allow an authorized transaction to be captured by invoking capture on the returned response object" do
    transaction = Clearhaus::Client.authorize(
        :amount             => 1,
        :card               => Mock.card,
        :currency           => "EUR",
        :ip                 => "1.1.1.1",
      )
    expect(transaction.capture.approved?).to be_true
  end

  it "Should allow attempts to capture a specific amount of a previously authorized transaction" do
    response = @client.authorize(
        :amount => 10,
        :card => Mock.card,
        :currency => "EUR",
        :ip => "1.1.1.1"
      )

    response = @client.capture(:amount => 5, :transaction_id => response.body[:id])
    expect(response.approved?).to be_true
    expect(response.declined?).to be_false
  end

  it "Should raise ClientError on attempts to capture a transaction that doesn't exist (hasn't been authorized yet)" do
    @loud_client = Clearhaus::Client.new(Mock.api_key, { :silent => false })
    expect{
      
      @loud_client.capture( :transaction_id => "unknown-transaction-id" )

    }.to raise_error(Clearhaus::Error::ClientError)
  end

  it "Should silently reject attempts to capture a transaction that doesn't exist" do
    response = @client.capture( :transaction_id => "unknown-transaction-id" )

    expect(response.approved?).to be_false
    expect(response.declined?).to be_true
  end

  it "Should allow an authorized transaction that hasn't been captured yet to be voided" do
    response = @client.authorize(
        :amount => 1,
        :card => Mock.card,
        :currency => "EUR",
        :ip => "1.1.1.1"
      )

    response = @client.void(:transaction_id => response.body[:id])
    expect(response.approved?).to be_true
    expect(response.declined?).to be_false
  end

  it "Should raise ClientError when trying to void a transaction that has been captured" do
    @loud_client = Clearhaus::Client.new(Mock.api_key, { :silent => false })

    response = @loud_client.charge(
        :amount => 1,
        :card => Mock.card,
        :currency => "EUR",
        :ip => "1.1.1.1" 
      )

    expect {
      @loud_client.capture(:transaction_id => response[:id])
    }.to raise_error(Clearhaus::Error::ClientError)
  end

  it "Should reject silently when trying to void a transaction that has already been captured" do
    response = @client.charge(
        :amount => 1,
        :card => Mock.card,
        :currency => "EUR",
        :ip => "1.1.1.1"
      )
    
    response = @client.capture(:transaction_id => response[:id])
    expect(response.approved?).to be_false
    expect(response.declined?).to be_true
  end

  it "Should allow a transaction to be refunded" do
    response = @client.charge(
        :amount => 1,
        :card => Mock.card,
        :currency => "EUR",
        :ip => "1.1.1.1" 
      )
    response = @client.refund(:transaction_id => response.body[:id])
    expect(response.approved?).to be_true
    expect(response.declined?).to be_false
  end

end