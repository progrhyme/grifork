class Grifork::Config
  attr_reader   :branches, :hosts, :log, :local_task, :remote_task, :grifork
  attr_accessor :griforkfile, :dry_run

  def initialize(args)
    args.each do |key, val|
      instance_variable_set("@#{key}", val)
    end
  end

  def mode
    @mode || :standalone
  end

  def dry_run?
    @dry_run ? true : false
  end

  class Log
    attr :file, :level

    def initialize(args)
      @file  = args[:file]
      @level = args[:level] || 'info'
    end
  end

  class Grifork
    attr :dir, :cmd, :login

    def initialize(&config)
      instance_eval(&config)
    end

    def workdir
      @tmpdir || Dir.tmpdir
    end

    private

    def user(login)
      @login = login
    end

    def chdir(path)
      @dir = path
    end

    def exec(cmd)
      @cmd = cmd
    end

    def tmpdir(path)
      @tmpdir = path
    end
  end
end
