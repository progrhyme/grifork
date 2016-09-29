class Grifork::CLI
  def run(argv)
    OptionParser.new do |opt|
      opt.on('-f', '--file Griforkfile') { |f| @taskfile      = f }
      opt.on('-o', '--override-by FILE') { |f| @override_file = f }
      opt.on('-r', '--on-remote')        { @on_remote = true }
      opt.on('-v', '--version')          { @version   = true }
      opt.parse!(argv)
    end
    if @version
      puts Grifork::VERSION
      exit
    end

    config = load_taskfiles.freeze
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

  def load_taskfiles
    puts "Load settings from #{taskfile}"
    dsl = Grifork::DSL.load_file(taskfile, on_remote: @on_remote)
    if @override_file
      dsl.load_and_merge_config_by!(@override_file)
    end
    dsl.to_config
  end


  def taskfile
    @taskfile || ENV['GRIFORKFILE'] || Grifork::DEFAULT_TASKFILE
  end
end
