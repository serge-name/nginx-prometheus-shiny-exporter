module Metric(T)

  def initialize
    @val = Hash(String, Hash(String, T)).new
  end

end


class MetricStatusCounter

  METRIC_NAME = "nginx_request_status"

  class Item
    def initialize
      @val = Hash(UInt16, UInt64).new
    end

    def each
      @val.each_key do |k|
        yield({k, @val[k]})
      end
    end

    def put(status)
      @val[status] = 0 unless @val.has_key?(status)

      @val[status] += 1_u64
    end
  end

  include Metric(Item)

  def inc(host, tag, status)
    @val[host] = Hash(String, Item).new unless @val.has_key?(host)
    @val[host][tag] = Item.new unless @val[host].has_key?(tag)
    @val[host][tag].put(status)
  end

  def to_s(io)
    io << "#<MetricStatusCounter:0x"
    io << object_id.to_s(16, io)
    io << " @val="
    io << @val
    io << ">"
  end

  def to_metrics
    m =  "# HELP #{METRIC_NAME} A metric\n"
    m += "# TYPE #{METRIC_NAME} counter\n"

    @val.each_key do |h|
      @val[h].each_key do |t|
        m_100_399 = 0_u64
        m_400_498 = 0_u64
        m_499     = 0_u64
        m_500_599 = 0_u64

        @val[h][t].each do |s, v|
          m += "#{METRIC_NAME}{host=\"#{h}\",tag=\"#{t}\",status=\"#{s}\"} #{v}\n"
          m_100_399 += v if s >= 100 && s <= 399
          m_400_498 += v if s >= 400 && s <= 498
          m_499     += v     if s == 499
          m_500_599 += v if s >= 500 && s <= 599
        end

        m += "#{METRIC_NAME}_100_399{host=\"#{h}\",tag=\"#{t}\"} #{m_100_399}\n" if m_100_399 > 0
        m += "#{METRIC_NAME}_400_498{host=\"#{h}\",tag=\"#{t}\"} #{m_400_498}\n" if m_400_498 > 0
        m += "#{METRIC_NAME}_499{host=\"#{h}\",tag=\"#{t}\"} #{m_499}\n"         if m_499 > 0
        m += "#{METRIC_NAME}_500_599{host=\"#{h}\",tag=\"#{t}\"} #{m_500_599}\n" if m_500_599 > 0
      end
    end

    m
  end

end


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

  def register(host, tag, time)
    @val[host] = Hash(String, Item).new unless @val.has_key?(host)
    @val[host][tag] = Item.new unless @val[host].has_key?(tag)
    @val[host][tag].put(time)
  end

  def to_s(io)
    io << "#<MetricReqTime:0x"
    io << object_id.to_s(16, io)
    io << " @val="
    io << @val
    io << ">"
  end

  def to_metrics
    m =  "# HELP #{METRIC_NAME} A metric\n"
    m += "# TYPE #{METRIC_NAME} gauge\n"

    @val.each_key do |h|
      @val[h].each_key do |t|
        if @val[h][t].counted? && @val[h][t].fresh?
          m += "#{METRIC_NAME}_avg{host=\"#{h}\",tag=\"#{t}\"\"} #{@val[h][t].avg}\n"
          m += "#{METRIC_NAME}_max{host=\"#{h}\",tag=\"#{t}\"\"} #{@val[h][t].max}\n"
        end
      end
    end

    m
  end
end
