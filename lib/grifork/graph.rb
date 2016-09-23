class Grifork::Graph
  include Grifork::Concerns::Configured
  attr :root, :nodes, :depth

  def initialize(hosts = [])
    @root  = Node.new(Grifork.localhost)
    @depth = @root.level
    @nodes = 1
    @acceptable_nodes = [@root]
    hosts.each do |h|
      self.add_node(h.to_node)
    end
  end

  def add_node(node)
    parent = @acceptable_nodes.first
    parent.add_child(node)
    unless parent.acceptable?
      @acceptable_nodes.shift
    end
    @last   = node
    @depth  = node.level
    @nodes += 1
    @acceptable_nodes << node
    parent
  end

  def print(node)
    label = node.host.hostname
    label ||= "level#{node.level}"
    puts %(  ) * node.level + label
    node.children.each do |child|
      print(child)
    end
    true
  end
end
