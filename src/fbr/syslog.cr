require "socket"

class Fbr::Syslog
  @s   : UDPSocket
#  @log : MyLog

  RX = %r{^<\d{1,3}>\S{3}\s+[0-3]?\d\s+[0-2]?\d:\d\d:\d\d\s(?:\S+\s)?(\S+):\s(.+)$}
  MSG_MAX_SIZE = 2048

  def initialize(host : String, port : Int, ch : Channel(LogMsg))
    @log = MyLog.new("syslog")
    @s = UDPSocket.new
    @s.bind(host, port)
    @ch = ch
    @log.info("syslog receiver started at udp://#{host}:#{port}")
  end

  def run
    spawn do
      loop do
        msg, ip = @s.receive(MSG_MAX_SIZE)

        begin
          @ch.send(parse(msg, ip))
        rescue e : ArgumentError
          @log.error("#{ip.to_s} sent an invalid message (#{e}): #{msg.to_s}")
          next
        end
      end
    end
  end

  private def parse(msg, ip) : LogMsg
    md = RX.match(msg)

    unless md
      raise ArgumentError.new "not matched as a syslog message"
    end

    mdrx = md.as(Regex::MatchData)
    tag = mdrx[1]
    payload = mdrx[2]

    LogMsg.new(tag, payload, ip)
  end
end
