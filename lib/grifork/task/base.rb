class Grifork::Task::Base
  include Grifork::Mixin::Loggable

  def initialize(&task)
    @task = task
  end

  def run(src, dst)
    instance_eval(&@task)
  end
end
