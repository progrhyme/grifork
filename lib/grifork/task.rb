class Grifork::Task
  def initialize(type, &task)
    @task = task
  end

  def run(src, dst)
    @task.call(src, dst)
  end
end
