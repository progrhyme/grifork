class Grifork::Runner
  include Grifork::Mixin::Configured

  def run(argv)
    config = load_taskfile.freeze
    #pp config # Debug
    Grifork.configure!(config)
    graph = Grifork::Graph.new(config.hosts)
    graph.print # Debug
    graph.run_task
  end

  def load_taskfile
    Grifork::DSL.load_file(taskfile).to_config
  end

  private

  def taskfile
    Grifork::DEFAULT_TASKFILE
  end
end
