require 'ostruct'
require 'pp' # Debug @todo Remove
require 'stdlogger'

class Grifork
  require_relative 'grifork/config'
  require_relative 'grifork/concerns/configured'
  require_relative 'grifork/logger'
  require_relative 'grifork/concerns/loggable'
  require_relative 'grifork/host'
  require_relative 'grifork/graph'
  require_relative 'grifork/graph/node'
  require_relative 'grifork/task'
  require_relative 'grifork/dsl'
  require_relative 'grifork/runner'

  DEFAULT_TASKFILE = 'Griforkfile'

  class << self
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
