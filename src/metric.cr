module Metric(T)

  def initialize
    @val = Hash(String, Hash(String, T)).new
  end

  def to_s(io)
    io << "#<" << {{@type.name.id.stringify}}
    io << ":0x" << object_id.to_s(16, io)
    io << " @val=" << @val
    io << ">"
  end

  def register(host, tag, value)
    @val[host] = Hash(String, T).new unless @val.has_key?(host)
    @val[host][tag] = T.new unless @val[host].has_key?(tag)
    @val[host][tag].put(value)
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

  class StatusRange
    getter c

    @c = 0_u64

    def initialize(min : UInt16, max : UInt16)
      @min  = min
      @max  = max
    end

    def initialize(exact : UInt16)
      @min  = exact
      @max  = exact
    end

    def name
      (@min == @max) ? "#{@min}" : "#{@min}-#{@max}"
    end

    def falls_into?(val : UInt16)
      (val >= @min) && (val <= @max)
    end

    def register(status : UInt16, value : UInt64)
      @c += value if falls_into?(status)
    end
  end

  include Metric(Item)

  def to_metrics
    m =  "# HELP #{METRIC_NAME} A metric\n"
    m += "# TYPE #{METRIC_NAME} counter\n"

    @val.each_key do |h|
      @val[h].each_key do |t|
        ranges = [
          StatusRange.new(100, 399),
          StatusRange.new(400, 498),
          StatusRange.new(499),
          StatusRange.new(500, 599),
        ]

        @val[h][t].each do |s, v|
          m += "#{METRIC_NAME}{host=\"#{h}\",tag=\"#{t}\",status=\"#{s}\"} #{v}\n"
          ranges.each do |r|
            r.register(s, v)
          end
        end

        ranges.each do |r|
          if r.c > 0
            m += "#{METRIC_NAME}_ranges{host=\"#{h}\",tag=\"#{t}\",range=\"#{r.name}\"} #{r.c}\n"
          end
        end
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
