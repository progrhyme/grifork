class Derooter::Host
  attr :hostname, :ipaddress
  def initialize
  end

  def to_node
    Derooter::Graph::Node.new(self)
  end
end
