class Grifork::Executor::Local
  include Grifork::Executable

  # Initialize with task
  # @param &task [Proc] task to execute
  def initialize(type, &task)
    @type = type
    @task = task
  end

  # Run the task
  def run
    instance_eval(&@task)
  end
end
