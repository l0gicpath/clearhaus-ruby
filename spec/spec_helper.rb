require "webmock/rspec"
require "clearhaus"
require "support/fake_clearhaus"

# WebMock.disable_net_connect!(:allow_localhost => true)
WebMock.allow_net_connect!

RSpec.configure do |config|
  # config.before(:each) do
  #   stub_request(:any, /gateway.clearhaus.com/).to_rack(FakeClearhaus)
  # end
end