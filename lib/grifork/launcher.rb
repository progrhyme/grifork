class Grifork::Launcher
  def launch(argv)
    OptionParser.new do |opt|
      opt.on('-f', '--file Griforkfile') { |file| @taskfile = file }
      opt.parse!(argv)
    end
    config = load_taskfile.freeze
    Grifork.configure!(config)
    graph = Grifork::Graph.new(config.hosts)
    #graph.print # Debug
    graph.fork_tasks
  end

  def load_taskfile
    puts "Load settings from #{taskfile}"
    Grifork::DSL.load_file(taskfile).to_config
  end

  private

  def taskfile
    @taskfile || ENV['GRIFORKFILE'] || Grifork::DEFAULT_TASKFILE
  end
end
