class Grifork::Graph::Node
  include Grifork::Concerns::Configured
  attr_accessor :level, :children, :parent, :host

  def initialize(host, parent: nil)
    @host     = host
    @parent   = parent
    @level    = parent ? parent.level + 1 : 0
    @children = []
  end

  def add_child(child)
    unless acceptable?
      raise "Unacceptable!"
    end
    @children << child
    child.parent = self
    child.level = level + 1
    child.children = []
  end

  def acceptable?
    children.size < config.jobs
  end
end
