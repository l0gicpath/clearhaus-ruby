require 'spec_helper'


describe Clearhaus do

  before(:all) do
    Clearhaus.api_key = Mock.api_key
  end

  before(:each) do
    # We set silent to false on some tests which has a side effect on the rest of the tests that follow
    # So before each we make sure it's set to true (default) and some tests will override it anyway
    Clearhaus.silent = true
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

  it "Should allow capturing a specific amount of an authorized transaction" do
    transaction1 = Clearhaus::Client.authorize(
        :amount             => 100,
        :card               => Mock.card,
        :currency           => "EUR",
        :ip                 => "1.1.1.1",
      )
    expect(transaction1.capture(50).approved?).to be_true

    transaction2 = Clearhaus::Client.authorize(
        :amount             => 100,
        :card               => Mock.card,
        :currency           => "EUR",
        :ip                 => "1.1.1.1",
      )

    expect(Clearhaus::Client.capture(transaction2.id, amount: 50).approved?).to be_true
  end

  it "Should raise ClientError on attempts to capture a transaction that doesn't exist (hasn't been authorized yet)" do
    Clearhaus.silent = false
    expect{
      
      Clearhaus::Client.capture("unknown-transaction-id")

    }.to raise_error(Clearhaus::Error::ClientError)
  end

  it "Should silently reject attempts to capture a transaction that doesn't exist" do
    transaction = Clearhaus::Client.capture("unknown-transaction-id")
    expect(transaction.approved?).to be_false
  end

  it "Should allow an authorized transaction that hasn't been captured yet to be voided" do
    transaction = Clearhaus::Client.authorize(
        :amount             => 100,
        :card               => Mock.card,
        :currency           => "EUR",
        :ip                 => "1.1.1.1",
      )
    transaction = Clearhaus::Client.void(transaction.id)
    expect(transaction.approved?).to be_true
  end

  it "Should raise ClientError when trying to void a transaction that has been captured" do
    Clearhaus.silent = false

    transaction = Clearhaus::Client.charge(
        :amount => 1,
        :card => Mock.card,
        :currency => "EUR",
        :ip => "1.1.1.1" 
      )

    expect {
      transaction.capture
    }.to raise_error(Clearhaus::Error::ClientError)
  end

  it "Should allow a transaction to be refunded" do
    transaction = Clearhaus::Client.charge(
        :amount => 1,
        :card => Mock.card,
        :currency => "EUR",
        :ip => "1.1.1.1" 
      )
    expect(transaction.refund.approved?).to be_true
  end

end