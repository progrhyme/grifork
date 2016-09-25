class Grifork::DSL
  class LoadError < StandardError; end

  def self.load_file(path)
    content = File.binread(path)
    dsl = new
    dsl.instance_eval(content)
    #pp dsl # Debug
    dsl
  end

  def initialize
    @config = {}
  end

  def to_config
    Grifork::Config.new(@config)
  end

  def branches(num)
    config_set(:branches, num)
  end

  def log(args)
    config_set(:log, Grifork::Config::Log.new(args))
  end

  def hosts(list)
    config_set(:hosts, list.map { |h| Grifork::Host.new(h) })
  end

  def local(&task)
    config_set(:local_task, Grifork::Task::Local.new(&task))
  end

  def remote(&task)
    config_set(:remote_task, Grifork::Task::Remote.new(&task))
  end

  private

  def config_set(key, value)
    if @config[key]
      raise LoadError, %(Config "#{key}" is already defined!)
    end
    @config[key] = value
  end
end
