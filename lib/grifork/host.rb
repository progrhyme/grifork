class Grifork::Host
  attr :hostname, :ipaddress
  def initialize(hostname = nil, ipaddress = nil)
    @hostname  = hostname
    @ipaddress = ipaddress
  end

  def to_node
    Grifork::Graph::Node.new(self)
  end
end