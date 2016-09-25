class Grifork::DSL
  class LoadError < StandardError; end

  def self.load_file(path)
    content = File.binread(path)
    dsl = new
    dsl.instance_eval(content)
    pp dsl
    dsl
  end

  def branches(num)
    init_property(:branches, num)
  end

  def log(stash)
    init_property(:log, stash)
  end

  def hosts(list)
    init_property(:hosts, list.map { |h| Grifork::Host.new(h) })
  end

  def local(&task)
    init_property(:localtask, Grifork::Task::Local.new(&task))
  end

  def remote(&task)
    init_property(:remotetask, Grifork::Task::Remote.new(&task))
  end

  private

  def init_property(prop, value)
    if instance_variable_get("@#{prop}")
      raise LoadError, %(@#{prop} is already defined!)
    end
    instance_variable_set("@#{prop}", value)
  end
end
