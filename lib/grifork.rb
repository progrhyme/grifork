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

  class << self
    def run(argv)
      graph = Graph.new(config.hosts)
      graph.print # Debug
      graph.run_task
    end

    def config
      @config ||= -> { Config.new }.call
    end

    # Overwrite @config mainly for debug or testing
    def configure!(config)
      @config = config
    end

    def logger
      @logger ||= -> { Grifork::Logger.create }.call
    end

    def localhost
      @localhost ||= -> { Host.new }.call
    end
  end
end
