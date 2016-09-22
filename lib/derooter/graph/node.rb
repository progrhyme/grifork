class Derooter::Graph::Node
  include Derooter::Concerns::Configured
  attr_accessor :level, :children, :parent, :next_sibling, :host

  def initialize(host, parent: nil)
    @host     = host
    @parent   = parent
    @level    = parent ? parent.level + 1 : 0
    @children = []
  end

  def add_child(child)
    if elder = @children.last
      elder.next_sibling = child
    end
    @children << child
    child.parent = self
    child.level = level + 1
    child.children = []
  end

  def acceptable?
    children.size < config.jobs
  end

  def first_sibling
    parent ? parent.children.first : nil
  end
end
