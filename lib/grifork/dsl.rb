class Grifork::DSL
  attr :config

  class LoadError < StandardError; end

  # Load DSL file to object
  # @param path [String]
  # @param on_remote [Boolean] whether process is invoked by remote host in :grifork mode or not
  def self.load_file(path, on_remote: false)
    content = File.binread(path)
    dsl = new(on_remote)
    dsl.instance_eval(content)
    dsl
  end

  def initialize(on_remote)
    @config    = {}
    @on_remote = on_remote
  end

  def to_config
    Grifork::Config.new(@config)
  end

  # Load another DSL file and merge its config
  def load_and_merge_config_by!(path)
    content = File.binread(path)
    other   = self.class.new(@on_remote)
    other.instance_eval(content)
    @config.merge!(other.config)
  end

  def mode(m)
    unless Grifork::MODES.has_key?(m)
      raise LoadError, "Undefined mode! #{m}"
    end
    config_set(:mode, m)
  end

  def grifork(&command)
    if @config[:mode] == :standalone
      raise LoadError, "Can't configure grifork in standalone mode"
    end
    @config[:mode] = :grifork
    config_set(:grifork, Grifork::Config::Grifork.new(&command))
  end

  def branches(num)
    config_set(:branches, num)
  end

  def log(args)
    config_set(:log, Grifork::Config::Log.new(args))
  end

  def hosts(list)
    config_set(:hosts, list)
  end

  def local(&task)
    return if @on_remote
    config_set(:local_task, Grifork::Executor::Task.new(:local, &task))
  end

  def remote(&task)
    if @on_remote
      config_set(:local_task, Grifork::Executor::Task.new(:local, &task))
    else
      config_set(:remote_task, Grifork::Executor::Task.new(:remote, &task))
    end
  end

  private

  def config_set(key, value)
    if @config[key]
      raise LoadError, %(Config "#{key}" is already defined!)
    end
    @config[key] = value
  end
end
