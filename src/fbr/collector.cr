class Fbr::Collector

  getter c_syslog
  getter c_web_cmd
  getter c_web_data

  COLLECTOR_BUF_IN_SIZE = 8
  COLLECTOR_BUF_OUT_SIZE = 10240

  def initialize(config : Config)
    @log = MyLog.new("collector", debug: config.debug)
    @log.info("collector started")
    @c_syslog = Channel(LogMsg).new(COLLECTOR_BUF_IN_SIZE)
    @c_web_cmd = Channel(Bool).new
    @c_web_data = Channel(String).new(COLLECTOR_BUF_OUT_SIZE)
    @m_status_counter = MetricStatusCounter.new
    @m_req_time = MetricReqTime.new
  end

  def run
    spawn do
      ra_syslog = @c_syslog.receive_select_action
      ra_web_cmd = @c_web_cmd.receive_select_action

      loop do
        if ra_syslog.ready?
          m = @c_syslog.receive
          @log.debug("got a message: #{m}")
          if m.m[:type] == LogMsg::MSG_STATUS
            host   = m.m[:host].as(String)
            tag    = m.m[:tag].as(String)
            status = m.m[:status].as(UInt16)
            @m_status_counter.register(host, tag, status)
            @log.debug("@m_status_counter == #{@m_status_counter}")
          elsif m.m[:type] == LogMsg::MSG_REQ_TIME
            host   = m.m[:host].as(String)
            tag    = m.m[:tag].as(String)
            time   = m.m[:time].as(Float64)
            @m_req_time.register(host, tag, time)
            @log.debug("@m_req_time == #{@m_req_time}")
          end
        end

        if ra_web_cmd.ready?
          @c_web_cmd.receive
          @c_web_data.send(@m_status_counter.to_metrics + @m_req_time.to_metrics)
        end

        sleep(0.01)
      end
    end
  end

end
