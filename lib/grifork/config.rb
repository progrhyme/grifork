class Grifork::Config
  attr :branches, :hosts, :log, :local_task, :remote_task, :grifork

  def initialize(args)
    args.each do |key, val|
      instance_variable_set("@#{key}", val)
    end
  end

  def mode
    @mode || :standalone
  end

  class Log
    attr :file, :level

    def initialize(args)
      @file  = args[:file]
      @level = args[:level] || 'info'
    end
  end

  class Grifork
    attr :dir, :cmd

    def initialize(&config)
      instance_eval(&config)
    end

    def workdir
      @tmpdir || Dir.tmpdir
    end

    private

    def chdir(path)
      @dir = path
    end

    def command(list)
      @cmd = list
    end

    def tmpdir(path)
      @tmpdir = path
    end
  end
end
