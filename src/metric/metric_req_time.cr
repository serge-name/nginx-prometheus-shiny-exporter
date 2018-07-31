class MetricReqTime

  METRIC_NAME = "nginx_request_time"

  class Item

    getter c_time
    getter c_req

    def initialize
      @c_time    = 0_f64
      @c_req     = 0_u64
    end

    def put(time)
      @c_time   += time
      @c_req    += 1_u64
    end
  end

  include Metric(Item)

  def to_metrics
    m =  "# HELP #{METRIC_NAME} A metric\n"
    m += "# TYPE #{METRIC_NAME} counter\n"

    @val.each_key do |h|
      @val[h].each_key do |t|
        m += "#{METRIC_NAME}_sum{host=\"#{h}\",tag=\"#{t}\"} #{@val[h][t].c_time}\n"
        m += "#{METRIC_NAME}_count{host=\"#{h}\",tag=\"#{t}\"} #{@val[h][t].c_req}\n"
      end
    end

    m
  end
end
