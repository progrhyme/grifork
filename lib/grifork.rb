require 'open3'
require 'optparse'
require 'ostruct'
require 'shellwords'
require 'net/ssh'
require 'parallel'
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
  require_relative 'grifork/dsl'
  require_relative 'grifork/launcher'
  require_relative 'grifork/version'

  DEFAULT_TASKFILE = 'Griforkfile'

  MODES = {
    standalone: 1,
    grifork:    2,
  }.freeze

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
