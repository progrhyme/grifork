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
end
