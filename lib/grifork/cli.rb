class Grifork::CLI
  def run(argv)
    OptionParser.new do |opt|
      opt.on('-f', '--file Griforkfile') { |file| @taskfile = file }
      opt.on('-v', '--version')          { @version = true }
      opt.parse!(argv)
    end
    if @version
      puts Grifork::VERSION
      exit
    end

    config = load_taskfile.freeze
    Grifork.configure!(config)

    graph = Grifork::Graph.new(config.hosts)
    #graph.print # Debug

    case config.mode
    when :standalone
      graph.launch_tasks
    when :grifork
      raise 'Not implemented yet!'
    else
      # Never comes here
      raise "Unexpected mode! #{config.mode}"
    end
  end

  private

  def load_taskfile
    puts "Load settings from #{taskfile}"
    Grifork::DSL.load_file(taskfile).to_config
  end


  def taskfile
    @taskfile || ENV['GRIFORKFILE'] || Grifork::DEFAULT_TASKFILE
  end
end
