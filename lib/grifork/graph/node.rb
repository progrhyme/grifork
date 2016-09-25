class Grifork::Graph::Node
  include Grifork::Mixin::Configured
  attr :index, :level, :number, :children, :parent, :host

  class << self
    attr :count
    def add
      @count ||= 0
      @count  += 1
    end
  end

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
    @index = self.class.count || 0
    self.class.add
  end

  def to_s
    "<#{index}:#{id}>"
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

  def local?
    parent ? false : true
  end

  def acceptable?
    children.size < config.branches
  end
end
