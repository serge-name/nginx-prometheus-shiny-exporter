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
