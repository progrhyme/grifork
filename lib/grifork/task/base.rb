class Grifork::Task::Base
  attr :src, :dst
  include Grifork::Mixin::Loggable

  def initialize(&task)
    @task = task
  end

  def run(src, dst)
    @src = src
    @dst = dst
    instance_eval(&@task)
  end
end
