class Grifork::Logger
  def self.create
    c = Grifork.config
    if c.log.file
      logger = StdLogger.create c.log.file
    else
      logger = StdLogger.create
    end
    logger.level = log_level(c.log.level)
    logger
  end

  def self.log_level(arg_level = 'info')
    level = arg_level.upcase
    if ::Logger.const_defined?(level)
      ::Logger.const_get(level)
    else
      ::Logger::INFO
    end
  end
end
