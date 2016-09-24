require 'ostruct'
require 'stdlogger'

class Grifork
  require_relative 'grifork/config'
  require_relative 'grifork/concerns/configured'
  require_relative 'grifork/logger'
  require_relative 'grifork/concerns/loggable'
  require_relative 'grifork/host'
  require_relative 'grifork/graph'
  require_relative 'grifork/graph/node'

  def self.run(argv)
    obj   = new
    graph = Graph.new(config.hosts)
    graph.run_task
  end

  def self.config
    @config ||= -> { Config.new }.call
  end

  def self.logger
    @logger ||= -> { Grifork::Logger.create }.call
  end

  def self.configure!(config)
    @config = config
  end

  def self.localhost
    @localhost ||= -> { Host.new }.call
  end
end
