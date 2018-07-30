class LogMsg

  getter m

  MSG_REQ_TIME = "reqt"
  MSG_STATUS   = "stts"

  def initialize(tag : String, payload : String, ip)
    parts = payload.split('|')
    @m = Hash(Symbol, String | Float32 | UInt16 | Time).new

    @m[:tag] = tag
    @m[:timestamp] = Time.utc_now

    if parts[0] === MSG_REQ_TIME && parts.size == 3
      @m[:type] = parts[0]
      @m[:host] = parts[1]
      @m[:time] = parts[2].to_f32
    elsif parts[0] === MSG_STATUS && parts.size == 3
      @m[:type] = parts[0]
      @m[:host] = parts[1]
      @m[:status] = parts[2].to_u16
    else
      raise ArgumentError.new "unknown message type"
    end
  end

  def to_s(io)
    io << "#<LogMsg:0x"
    io << object_id.to_s(16, io)
    io << " @m="
    io << @m
    io << ">"
  end

end
