require "spec"
require "socket"
require "../src/log_msg"

describe LogMsg do

  describe ".new" do
    address = Socket::IPAddress.new("127.0.0.1", 12345)

    it "creates an instance for a request time message" do
      payload = "#{LogMsg::MSG_REQ_TIME}|some_host|0.002"
      msg = LogMsg.new("some_tag", payload, address)
    end

    it "creates an instance for a status message" do
      payload = "#{LogMsg::MSG_STATUS}|some_host|204"
      msg = LogMsg.new("some_tag", payload, address)
    end

    it "fails on unknown message" do
      payload = "BRqTvm4umKC8M3hI"
      expect_raises ArgumentError do
        msg = LogMsg.new("some_tag", payload, address)
      end
    end
  end

end
