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
