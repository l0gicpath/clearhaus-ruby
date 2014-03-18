require 'spec_helper'


describe Clearhaus do
  it 'Should allow the authorization of a certain amount' do
    client = Clearhaus::Client.new("apikey")
    card = {
        :number => 4111111111111111,
        :expire_month => 12,
        :expire_year => 2017,
        :csc => 123
      }
    response = client.authorize(1, card, {
        :currency => "EUR",
        :ip => "1.1.1.1",
        :text_on_statement => "authorization-0"
      })
    expect(response['status']['code']).to eq 20000
  end
end