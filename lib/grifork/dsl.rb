# DSL parser for *Griforkfile*
#
# _Griforkfile_ is interpreted in instance context by an object of this Class.
class Grifork::DSL
  attr :config

  class LoadError < StandardError; end

  # Load DSL file to object
  # @return [Grifork::DSL]
  # @param path [String] path of DSL file
  # @param on_remote [Boolean] whether process is invoked by remote host in :grifork mode or not
  def self.load_file(path, on_remote: false)
    content = File.binread(path)
    dsl = new(on_remote)
    dsl.instance_eval(content)
    dsl
  end

  def initialize(on_remote)
    @config    = {}
    @on_remote = on_remote
  end

  # Creates {Grifork::Config} object from holding properties
  # @return [Grifork::Config]
  def to_config
    Grifork::Config.new(@config)
  end

  # Load another DSL file and merge its config
  def load_and_merge_config_by!(path)
    content = File.binread(path)
    other   = self.class.new(@on_remote)
    other.instance_eval(content)
    @config.merge!(other.config)
  end

  # Grifork mode: How it works
  # @param m [Symbol] +:standalone+ or +:grifork+. Defaults to +:standalone+
  def mode(m)
    unless Grifork::MODES.has_key?(m)
      raise LoadError, "Undefined mode! #{m}"
    end
    config_set(:mode, m)
  end

  # Configure grifork settings for +:grifork+ mode
  # @param &command [Proc]
  # @see Grifork::Config::Grifork.initialize
  def grifork(&command)
    if @config[:mode] == :standalone
      raise LoadError, "Can't configure grifork in standalone mode"
    end
    @config[:mode] = :grifork
    config_set(:grifork, Grifork::Config::Grifork.new(&command))
  end

  # Branches number for tree of host nodes
  def branches(num)
    config_set(:branches, num)
  end

  # Configure logging
  # @param args [Hash]
  # @see Grifork::Config::Log.initialize
  def log(args)
    config_set(:log, Grifork::Config::Log.new(args))
  end

  # Forking method to exec tasks in parallel.
  # @param how [:Symbol] +:in_threads+ or +:in_processes+. Defaults to +:in_threads+
  # @see https://github.com/grosser/parallel
  def parallel(how)
    unless %i(in_threads in_processes).include?(how)
      raise LoadError, "Invalid parallel mode! #{how.inspect} / must be :in_threads or :in_processes"
    end
    config_set(:parallel, how)
  end

  # Host list as targets of tasks
  # @param hosts [Array<String>] List of resolvable hostnames
  def hosts(list)
    config_set(:hosts, list)
  end

  # Configure net-ssh options
  # @params props [Hash] Options for Net::SSH
  # @example
  #   # Password authentication
  #   ssh user: 'someone', password: 'xxx'
  #   # Private key authentication
  #   ssh user: 'someone', keys: ['path/to/priv_key'], passphrase: 'xxx'
  # @see https://github.com/net-ssh/net-ssh
  def ssh(props)
    invalid_options = props.keys - Net::SSH::VALID_OPTIONS
    if invalid_options.size > 0
      raise LoadError, "#{invalid_options} are invalid for Net::SSH!"
    end
    config_set(:ssh, Grifork::Config::SSH.new(props))
  end

  # Configure rsync command options
  # @params props [Array, Hash] rsync option parameters
  # @example
  #   # Available full Hash options are bellow
  #   rsync delete: true, bwlimit: 4096, verbose: false, excludes: %w(.git* .svn*), rsh: nil, dry_run: false
  #   # This is the same with above by Array format:
  #   rsync %w(-az --delete --bwlimit=4096 --exclude=.git* --exclude=.svn*)
  #   # You can set more options by Array format:
  #   rsync %w(-azKc -e=rsh --delete --bwlimit=4096 --exclude-from=path/to/rsync.excludes)
  def rsync(props)
    config_set(:rsync, Grifork::Config::Rsync.new(props))
  end

  # Define tasks to execute at localhost
  # @param &task [Proc] Codes to be executed by an object of {Grifork::Executor::Carrier}
  # @note In +:grifork+ mode, this is executed only at localhost
  def local(&task)
    return if @on_remote
    config_set(:local_task, Grifork::Executor::Carrier.new(:local, &task))
  end

  # Define tasks to execute at remote host
  # @param &task [Proc] Codes to be executed by an object of {Grifork::Executor::Carrier}
  # @note In +:standalone+ mode, the task is executed at localhost actually.
  #  In +:grifork+ mode, it is executed at remote hosts via +grifork+ command on remote hosts
  def remote(&task)
    if @on_remote
      config_set(:local_task, Grifork::Executor::Carrier.new(:local, &task))
    else
      config_set(:remote_task, Grifork::Executor::Carrier.new(:remote, &task))
    end
  end

  # Define tasks to execute at localhost before starting procedure
  # @param &task [Proc] Codes to be executed by an object of {Grifork::Executor::Local}
  # @note In +:grifork+ mode, this is executed only at localhost
  def prepare(&task)
    return if @on_remote
    config_set(:prepare_task, Grifork::Executor::Local.new(:prepare, &task))
  end

  # Define tasks to execute at localhost in the end of procedure
  # @param &task [Proc] Codes to be executed by an object of {Grifork::Executor::Local}
  # @note In +:grifork+ mode, this is executed only at localhost
  def finish(&task)
    return if @on_remote
    config_set(:finish_task, Grifork::Executor::Local.new(:finish, &task))
  end

  private

  def config_set(key, value)
    if @config[key]
      raise LoadError, %(Config "#{key}" is already defined!)
    end
    @config[key] = value
  end
end
