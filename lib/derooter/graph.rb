class Derooter::Graph
  include Derooter::Concerns::Configured
  attr :root

  def initialize(hosts)
    @root = Node.new(Derooter.localhost)
    hosts.each do |h|
      self.add_node(h.to_node)
    end
  end

  def add_node(node)
    parent = search_acceptable_node(root)
    parent.add_child(node)
    parent
  end

  def print(node)
    puts %(  ) * node.level + node.level.to_s
    node.children.each do |child|
      print(child)
    end
    if node.next_sibling
      print(node.next_sibling)
    end
  end

  private

  def search_acceptable_node(node, level: nil)
    return node if node.acceptable?
    level ||= node.level
    level = 1 if level.zero?

    if level <= node.level
      if node.next_sibling
        return search_acceptable_node(node.next_sibling, level: level)
      end
      return search_acceptable_node(node.first_sibling, level: node.level + 1)
    end

    node.children.each do |child|
      return child if search_acceptable_node(child, level: level)
    end
    if node.next_sibling
      return search_acceptable_node(node.next_sibling, level: level)
    end

    return search_acceptable_node(node.first_sibling, level: level + 1)
  end
end
