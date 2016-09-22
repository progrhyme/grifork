class Derooter::Host
  attr :hostname, :ipaddress
  def initialize(hostname = nil, ipaddress = nil)
    @hostname  = hostname
    @ipaddress = ipaddress
  end

  def to_node
    Derooter::Graph::Node.new(self)
  end
end
