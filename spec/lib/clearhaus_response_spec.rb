require 'spec_helper'

describe Clearhaus::HttpClient::Response do
  before(:all) do
    # Wrap our mock response in a struct under a body variable because Response#initialize expects a 
    # response object with a body variable
    R = Struct.new(:body)
    @valid_response = R.new(Mock.valid_response)
    puts "#{@valid_response.inspect}"
  end

  it "should generate a helper method approved? that returns true for a 20000 request" do
    response = Clearhaus::HttpClient::Response.new(@valid_response)
    expect(response).to respond_to(:approved?)
    expect(response.approved?).to be_true
  end

  it "should generate a helper method declined? that returns false for a 20000 request" do
    response = Clearhaus::HttpClient::Response.new(@valid_response)
    expect(response).to respond_to(:declined?)
    expect(response.declined?).to be_false
  end

  it "should generate a helper method challenged? that returns false for a 20000 request" do
    response = Clearhaus::HttpClient::Response.new(@valid_response)
    expect(response).to respond_to(:challenged?)
    expect(response.challenged?).to be_false
  end

  it "should allow accessing response body as a hash object via [:response_key]" do
    response = Clearhaus::HttpClient::Response.new(@valid_response)
    expect(response[:id]).to eq(Mock.valid_response[:id])
  end

  it "should allow accessing response body using .body" do
    response = Clearhaus::HttpClient::Response.new(@valid_response)
    expect(response.body[:id]).to eq(Mock.valid_response[:id])
  end

end