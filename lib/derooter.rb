class Derooter
  require_relative 'derooter/config'
  require_relative 'derooter/concerns/configured'
  require_relative 'derooter/host'
  require_relative 'derooter/graph'
  require_relative 'derooter/graph/node'

  def self.run(argv)
    obj = new
    obj.sync_hosts
  end

  def self.config
    @config ||= -> { Config.new }.call
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
