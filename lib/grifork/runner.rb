class Grifork::Runner
  include Grifork::Mixin::Configured

  def run(argv)
    load_taskfile
    graph = Grifork::Graph.new(config.hosts)
    #graph.print # Debug
    #graph.run_task
  end

  def load_taskfile
    dsl = Grifork::DSL.load_file(taskfile)
  end

  private

  def taskfile
    Grifork::DEFAULT_TASKFILE
  end
end
