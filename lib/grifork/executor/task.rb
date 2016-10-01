class Grifork::Executor::Task
  include Grifork::Executable
  attr :src, :dst

  def initialize(type, &task)
    @type = type
    @task = task
  end

  def run(src, dst)
    @src = src
    @dst = dst
    instance_eval(&@task)
  end
end
