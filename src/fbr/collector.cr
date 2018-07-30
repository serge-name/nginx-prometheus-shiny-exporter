class Fbr::Collector

  getter c_syslog
  getter c_web_cmd
  getter c_web_data

  COLLECTOR_BUF_IN_SIZE = 8
  COLLECTOR_BUF_OUT_SIZE = 10240

  def initialize
    @log = MyLog.new("collector")
    @log.info("collector started")
    @c_syslog = Channel(LogMsg).new(COLLECTOR_BUF_IN_SIZE)
    @c_web_cmd = Channel(Bool).new
    @c_web_data = Channel(String).new(COLLECTOR_BUF_OUT_SIZE)
    @m_status_counter = MetricStatusCounter.new
  end

  def run
    spawn do
      ra_syslog = @c_syslog.receive_select_action
      ra_web_cmd = @c_web_cmd.receive_select_action

      loop do
        if ra_syslog.ready?
          m = @c_syslog.receive
          @log.info("got a message: #{m}")
          if m.m[:type] == LogMsg::MSG_STATUS
            host   = m.m[:host].as(String)
            tag    = m.m[:tag].as(String)
            status = m.m[:status].as(UInt16)
            @m_status_counter.inc(host, tag, status)

            @log.debug("@m_status_counter == #{@m_status_counter}")
          end
        end

        if ra_web_cmd.ready?
          @c_web_cmd.receive
          @c_web_data.send(@m_status_counter.to_metrics) # FIXME: send everything as one String
        end

        sleep(0.01)
      end
    end
  end

end
