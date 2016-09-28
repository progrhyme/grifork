class Grifork::DSL
  class LoadError < StandardError; end

  # Load DSL file to object
  def self.load_file(path)
    content = File.binread(path)
    dsl = new
    dsl.instance_eval(content)
    dsl
  end

  def initialize
    @config = {}
  end

  def to_config
    Grifork::Config.new(@config)
  end

  def mode(m)
    unless Grifork::MODES.has_key?(m)
      raise LoadError, "Undefined mode! #{m}"
    end
    config_set(:mode, m)
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
    config_set(:local_task, Grifork::Task.new(:local, &task))
  end

  def remote(&task)
    config_set(:remote_task, Grifork::Task.new(:remote, &task))
  end

  private

  def config_set(key, value)
    if @config[key]
      raise LoadError, %(Config "#{key}" is already defined!)
    end
    @config[key] = value
  end
end
