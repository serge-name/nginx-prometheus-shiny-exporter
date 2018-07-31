require "option_parser"

class Config

  getter debug
  getter web_host
  getter web_port
  getter syslog_host
  getter syslog_port

  # https://github.com/prometheus/prometheus/wiki/Default-port-allocations
  DEFAULT_PORT = 9467

  def initialize
    @debug       = false
    @web_host    = "0.0.0.0"
    @web_port    = DEFAULT_PORT
    @syslog_host = "127.0.0.1"
    @syslog_port = DEFAULT_PORT

    OptionParser.parse! do |parser|
      parser.banner = "Usage: <CMD> [arguments]"
      parser.on("-d", "--debug", "Enable debug output") { @debug = true }
      parser.on("-w [HOST]:PORT", "--listen-web=[HOST]:PORT", "bind web service to specified HOST ('0.0.0.0' if omited) and PORT") { |bind|
        @web_host, @web_port = parse_bind(parser, bind, default_host: "0.0.0.0")
      }
      parser.on("-s [HOST]:PORT", "--listen-syslog=[HOST]:PORT", "bind syslog UDP receiver to specified HOST ('0.0.0.0' if omited) and PORT") { |bind|
        @syslog_host, @syslog_port = parse_bind(parser, bind)
      }
      parser.on("-h", "--help",  "Show this help")      { print_help(parser) }
      parser.invalid_option do |flag|
        print_error(parser, "#{flag} is not a valid option.")
      end
    end
  end

  private def parse_bind(parser, bind, default_host = "127.0.0.1")
    print_error(parser, "must specify ':PORT'") unless bind.includes?(":")
    parts = bind.split(':')
    print_error(parser, "bad argument: '#{bind}'") if parts.size > 2

    {
      (parts[0].empty?) ? default_host : parts[0],
      parts[1].to_i32,
    }
  end

  private def print_error(parser, message)
    STDERR.puts "ERROR: #{message}"
    STDERR.puts parser
    exit(1)
  end

  private def print_help(parser)
    STDERR.puts parser
    exit(0)
  end

end
