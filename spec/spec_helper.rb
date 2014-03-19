require "webmock/rspec"
require "clearhaus"
require "support/mock"
require "support/fake_clearhaus"

# WebMock.disable_net_connect!(:allow_localhost => true)
WebMock.allow_net_connect!

RSpec.configure do |config|
  Mock.load!("#{ File.dirname(__FILE__) }/support/fixtures/mock_data.yml")
  # config.before(:each) do
  #   stub_request(:any, /gateway.clearhaus.com/).to_rack(FakeClearhaus)
  # end
end