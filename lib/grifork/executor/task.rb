class Grifork::Executor::Task
  include Grifork::Executable
  attr :src, :dst

  # Initialize with task
  # @param &task [Proc] task to execute
  def initialize(type, &task)
    @type = type
    @task = task
  end

  # Run the task
  # @param src [String] Source hostname
  # @param dst [String] Target hostname
  def run(src, dst)
    @src = src
    @dst = dst
    instance_eval(&@task)
  end

  private

  # Shorthand for +rsync+ command.
  # Sync contents to #dst host
  # @param from [String] Path to source file or directory
  # @param to   [String] Path to destination at remote host.
  #  If you omit this param, it will be the same with +from+ param
  def rsync(from, to = nil)
    to ||= from
    sh :rsync, [*config.rsync.options, from, "#{dst}:#{to}"]
  end

  # Shorthand for +rsync+ command run by +ssh+ to #src host
  # Sync contents from #src to #dst host
  # @note This is for +remote+ task on +:standalone+ mode
  # @param from [String] Path to source file or directory
  # @param to   [String] Path to destination at remote host.
  #  If you omit this param, it will be the same with +from+ param
  # @param user [String] see #ssh
  def rsync_remote(from, to = nil, user: nil)
    to ||= from
    ssh src, :rsync, [*config.rsync.options, from, "#{dst}:#{to}"], user: user
  end
end
