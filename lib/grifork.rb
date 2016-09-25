require 'open3'
require 'ostruct'
require 'pp' # Debug @todo Remove
require 'stdlogger'

class Grifork
  require_relative 'grifork/config'
  require_relative 'grifork/mixin/configured'
  require_relative 'grifork/logger'
  require_relative 'grifork/mixin/loggable'
  require_relative 'grifork/host'
  require_relative 'grifork/graph'
  require_relative 'grifork/graph/node'
  require_relative 'grifork/task'
  require_relative 'grifork/task/base'
  require_relative 'grifork/task/local'
  require_relative 'grifork/task/remote'
  require_relative 'grifork/dsl'
  require_relative 'grifork/runner'

  DEFAULT_TASKFILE = 'Griforkfile'

  class << self
    attr :config

    def configure!(config)
      @config = config
    end

    def logger
      @logger ||= -> { Grifork::Logger.create }.call
    end

    def localhost
      @localhost ||= -> {
        Host.new(hostname: 'localhost', ipaddress: '127.0.0.1')
      }.call
    end
  end
end
