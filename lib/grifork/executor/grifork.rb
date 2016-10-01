class Grifork::Executor::Grifork
  include Grifork::Executable
  attr :config

  # @param cfg [Grifork::Config::Grifork] configured by DSL#grifork
  def initialize(cfg)
    @config = cfg
  end

  # Run grifork command on remote node:
  #  1. Create Griforkfile and copy it to remote
  #  2. ssh remote host and exec grifork
  def run(node)
    c = config
    ssh node.host, %(test -d "#{c.workdir}" || mkdir -p "#{c.workdir}"), user: c.login
    sh :rsync, ['-avzc', Grifork.config.griforkfile, "#{node.host}:#{c.workdir}/Griforkfile"]
    hostsfile = Tempfile.create('Griforkfile.hosts')
    hostsfile.write(<<-EOS)
      hosts #{node.all_descendant_nodes.map(&:host)}
    EOS
    hostsfile.flush
    sh :rsync, ['-avzc', hostsfile.path, "#{node.host}:#{c.workdir}/Griforkfile.hosts"]
    hostsfile.close
    ssh node.host, %(cd #{c.dir} && #{c.cmd} --file #{c.workdir}/Griforkfile --override-by #{c.workdir}/Griforkfile.hosts --on-remote), [], user: c.login
  end
end
