class Grifork::Graph
  include Grifork::Configured
  include Grifork::Loggable
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

  # Launch local and remote tasks through whole graph
  def launch_tasks
    # level = 1
    Parallel.map(root.children, in_threads: root.children.size) do |node|
      logger.info("Run locally. localhost => #{node.host}")
      config.local_task.run(root.host, node.host)
    end
    # level in (2..depth)
    fork_remote_tasks(root.children)
  end

  # Print graph structure for debug usage
  def print(node = root)
    puts %(  ) * node.level + "#{node}"
    node.children.each do |child|
      print(child)
    end
    true
  end

  private

  # Launch remote tasks recursively
  def fork_remote_tasks(parents)
    families        = []
    next_generation = []
    parents.each do |parent|
      if parent.children.size.zero?
        logger.debug("#{parent} Reached leaf. Nothing to do.")
        next
      end
      parent.children.each do |child|
        families        << [parent, child]
        next_generation << child
      end
    end

    if families.size.zero?
      logger.info("Reached bottom of the tree. Nothing to do.")
      return
    end

    Parallel.map(families, in_threads: families.size) do |family|
      parent = family[0]
      child  = family[1]
      logger.info("Run remote [#{parent.level}]. #{parent.host.hostname} => #{child.host.hostname}")
      config.remote_task.run(parent.host, child.host)
    end

    fork_remote_tasks(next_generation)
  end
end
