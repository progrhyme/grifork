class Grifork::Config
  attr :branches, :hosts, :log, :local_task, :remote_task

  def initialize(args)
    args.each do |key, val|
      instance_variable_set("@#{key}", val)
    end
  end

  class Log
    attr :file, :level

    def initialize(args)
      @file  = args[:file]
      @level = args[:level]
    end
  end
end
