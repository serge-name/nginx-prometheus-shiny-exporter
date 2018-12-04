require "socket"

class SdNotify
  @socket : UNIXSocket | Nil
  @tmout : UInt32

  TMOUT_DEFAULT = 2_u32

  def initialize(config)
    @log = MyLog.new("sd_notify", debug: config.debug)
    @socket = get_socket
    @log.debug("%susing systemd notifications" % (supported? ? "" : "not "))

    @tmout = get_tmout
    @log.debug("sleep duration is #{@tmout}s")
  end

  def supported?
    !@socket.nil?
  end

  def sleep
    @log.debug("sleep")
    sleep(@tmout)
  end

  def ready
    sd_send("READY=1")
  end

  def watchdog
    # Nothing wrong will happen if we send this notification
    # when watchdog is disabled, so no extra conditions.
    sd_send("WATCHDOG=1")
  end

  private def sd_send(msg)
    if supported?
      @log.debug("going to send message: #{msg}")
      @socket.as(UNIXSocket).puts(msg)
    end
  end

  private def get_socket : UNIXSocket | Nil
    begin
      UNIXSocket.new(ENV["NOTIFY_SOCKET"], Socket::Type::DGRAM)
    rescue KeyError
      nil
    rescue ex: Errno
      @log.error(ex.message.as(String))

      nil
    end
  end

  private def get_tmout : UInt32
    tmout = begin
      ENV["WATCHDOG_USEC"].to_u32 / 1_000_000
    rescue exception
      TMOUT_DEFAULT
    end

    (tmout < 1) ? 1_u32 : tmout
  end
end
