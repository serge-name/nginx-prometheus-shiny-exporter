require "spec"
require "../src/my_log"

describe MyLog do

  describe ".new" do
    it "creates new logger with prefix" do
      logger = MyLog.new("prefix")
    end
  end

end
