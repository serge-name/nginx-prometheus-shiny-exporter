class MetricReqTime

  METRIC_NAME = "nginx_request_time"

  class Item

    TIME_STEP = Time::Span.new(seconds: 10, nanoseconds: 0) # FIXME: make it configurable

    def initialize
      # FIXME: rm redundancy
      @c_time    = 0_f64
      @c_req     = 0_u64
      @time_max  = 0_f64
      @timestamp = Time.utc_now
    end

    def reset
      @c_time    = 0_f64
      @c_req     = 0_u64
      @time_max  = 0_f64
      @timestamp = Time.utc_now
    end

    def fresh?
      (Time.utc_now - @timestamp.as(Time)) <= TIME_STEP
    end

    def counted?
      @c_req > 0
    end

    def avg
      @c_time / @c_req
    end

    def max
      @time_max
    end

    def put(time)
      reset unless fresh?

      @c_time   += time
      @time_max  = time if @time_max < time
      @c_req    += 1_u64
    end
  end

  include Metric(Item)

  def to_metrics
    m =  "# HELP #{METRIC_NAME} A metric\n"
    m += "# TYPE #{METRIC_NAME} gauge\n"

    @val.each_key do |h|
      @val[h].each_key do |t|
        if @val[h][t].counted? && @val[h][t].fresh?
          m += "#{METRIC_NAME}_avg{host=\"#{h}\",tag=\"#{t}\"} #{@val[h][t].avg}\n"
          m += "#{METRIC_NAME}_max{host=\"#{h}\",tag=\"#{t}\"} #{@val[h][t].max}\n"
        end
      end
    end

    m
  end
end
