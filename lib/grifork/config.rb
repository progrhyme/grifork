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

  def parallel
    @parallel || :in_threads
  end

  def dry_run?
    @dry_run ? true : false
  end

  def ssh
    @ssh || SSH.new
  end

  # Build +rsync+ command-line options from +@rsync+ and +@ssh+ objects
  # @return [Array<String>] +rsync+ command options
  # @see Rsync
  # @see SSH
  def rsync_opts
    @rsync ||= Rsync.new
    opts = @rsync.options
    if opts.grep(/^(-e|--rsh)[= ]\S+/).size.zero?
      opts << %(--rsh="#{ssh.command_for_rsync}")
    end
    opts
  end

  class Log
    attr :file, :level

    def initialize(args)
      @file  = args[:file]
      @level = args[:level] || 'info'
    end
  end

  class SSH
    attr :options
    def initialize(opts = {})
      @options = opts
    end

    # Build +ssh+ command with options
    # @return [String] +ssh+ command with options
    def command_for_rsync
      args = []
      args << "-l #{@options[:user]}" if @options[:user]
      args << "-p #{@options[:port]}" if @options[:port]
      if @options[:keys]
        @options[:keys].each { |key| args << "-i #{key}" }
      end
      "ssh #{args.join(' ')}"
    end
  end

  class Rsync
    def initialize(args = %w(-az --delete))
      case args
      when Array
        @options = args
      when Hash
        @delete   = args[:delete]   || true
        @verbose  = args[:verbose]  || false
        @bwlimit  = args[:bwlimit]  || nil
        @excludes = args[:excludes] || []
        @rsh      = args[:rsh]      || nil
        @dry_run  = args[:dry_run]  || false
      end
    end

    def options
      @options ||= -> {
        opts = []
        opts << ( @verbose ? '-avz' : '-az' )
        opts << '--dry-run'             if @dry_run
        opts << '--delete'              if @delete
        opts << %(--rsh="#{@rsh}")      if @rsh
        opts << "--bwlimit=#{@bwlimit}" if @bwlimit
        if @excludes.size > 0
          @excludes.each { |ex| opts << "--exclude=#{ex}" }
        end
        opts
      }.call
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
