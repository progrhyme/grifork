class Grifork::Graph
  include Grifork::Concerns::Configured
  attr :root, :nodes, :depth

  def initialize(hosts = [])
    @root  = Node.new(Grifork.localhost)
    @depth = @root.level
    @nodes = 1
    @acceptable_nodes = [@root]
    hosts.each do |host|
      self.add_node_by_host(host)
    end
  end

  def run_task
    1.upto(depth).each do |level|
      # run for each level
    end
  end

  def add_node_by_host(host)
    parent = @acceptable_nodes.first
    node   = Node.new(host, parent: parent)
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

  # For debug
  def print(node = root)
    puts %(  ) * node.level + "#{node.id} # #{node.index}"
    node.children.each do |child|
      print(child)
    end
    true
  end
end
