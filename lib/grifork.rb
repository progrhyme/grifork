class Grifork
  require_relative 'grifork/config'
  require_relative 'grifork/concerns/configured'
  require_relative 'grifork/host'
  require_relative 'grifork/graph'
  require_relative 'grifork/graph/node'

  def self.run(argv)
    obj = new
    obj.sync_hosts
  end

  def self.config
    @config ||= -> { Config.new }.call
  end

  def self.configure!(config)
    @config = config
  end

  def config
    self.class.config
  end

  def sync_hosts
    graph = Graph.new(config.hosts)
  end

  def self.localhost
    @localhost ||= -> { Host.new }.call
  end
end
