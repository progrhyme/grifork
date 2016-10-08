class Grifork::Executor::Task
  include Grifork::Executable

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
    Thread.current[:src] = src
    Thread.current[:dst] = dst
    instance_eval(&@task)
  end

  private

  def src
    Thread.current[:src]
  end

  def dst
    Thread.current[:dst]
  end

  # Wrapper for {Grifork::Executable#rsync}
  def rsync(from, to = nil)
    super(dst, from, to)
  end

  # Wrapper for {Grifork::Executable#rsync_remote}
  # @note This is for +remote+ task on +:standalone+ mode
  def rsync_remote(from, to = nil)
    super(src, dst, from, to)
  end
end
