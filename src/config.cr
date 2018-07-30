require "option_parser"

class Config

  getter debug
  getter web_host
  getter web_port
  getter syslog_host
  getter syslog_port

  def initialize
    @debug       = false
    @web_host    = "0.0.0.0"
    @web_port    = 10018
    @syslog_host = "127.0.0.1"
    @syslog_port = 10019

    OptionParser.parse! do |parser|
      parser.banner = "Usage: <CMD> [arguments]"
      parser.on("-d", "--debug", "Enable debug output") { @debug = true }
      parser.on("-h", "--help",  "Show this help")      { puts parser }
      parser.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end
  end

end
