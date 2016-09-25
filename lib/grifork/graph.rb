class Grifork::Graph
  include Grifork::Mixin::Configured
  include Grifork::Mixin::Loggable
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

  def run_task(node = root)
    #currents = [node]
    if node.children.size.zero?
      logger.debug("#{node} Reached leaf. Nothing to do.")
    end
    # @todo Use Parallel
    node.children.each do |child|
      if node.local?
        logger.info("Run locally. #{node} => #{child}")
        config.local_task.run(node.host, child.host)
      else
        logger.info("Run remote. #{node} => #{child}")
        config.remote_task.run(node.host, child.host)
      end
    end
    node.children.each do |child|
      run_task(child)
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
    puts %(  ) * node.level + "#{node}"
    node.children.each do |child|
      print(child)
    end
    true
  end
end
