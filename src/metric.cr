class MetricStatusCounter

  METRIC_NAME = "nginx_request_status"

  def initialize
    @val = Hash(String, Hash(String, Hash(UInt16, UInt64))).new
  end

  def inc(host, tag, status)
    @val[host] = Hash(String, Hash(UInt16, UInt64)).new unless @val.has_key?(host)
    @val[host][tag] = Hash(UInt16, UInt64).new unless @val[host].has_key?(tag)
    @val[host][tag][status] = 0 unless @val[host][tag].has_key?(status)

    @val[host][tag][status] += 1.to_u64
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
        m_100_399 = 0.to_u64
        m_400_498 = 0.to_u64
        m_499 = 0.to_u64
        m_500_599 = 0.to_u64

        @val[h][t].each_key do |s|
          m += "#{METRIC_NAME}{host=\"#{h}\",tag=\"#{t}\",status=\"#{s}\"} #{@val[h][t][s]}\n"
          m_100_399 += @val[h][t][s] if s >= 100 && s <= 399
          m_400_498 += @val[h][t][s] if s >= 400 && s <= 498
          m_499 += @val[h][t][s]     if s == 499
          m_500_599 += @val[h][t][s] if s >= 500 && s <= 599
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

#class MetricGauge
#end
