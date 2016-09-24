class Grifork::Graph::Node
  include Grifork::Concerns::Configured
  attr :index, :level, :number, :children, :parent, :host

  module ClassMethods
    attr :count
    def add
      @count ||= 0
      @count  += 1
    end
  end

  extend ClassMethods

  def initialize(host, parent: nil)
    @host     = host
    @children = []
    if parent
      @parent = parent
      @level  = parent.level + 1
      @number = parent.children.size
    else
      @level  = 0
      @number = 0
    end
    @index = self.class.count
    self.class.add
  end

  def id
    @id ||= -> {
      if parent
        "#{parent.id}-#{level}.#{number}"
      else
        "#{level}.#{number}"
      end
    }.call
  end

  def add_child(child)
    unless acceptable?
      raise "Unacceptable!"
    end
    @children << child
  end

  def acceptable?
    children.size < config.branches
  end
end
