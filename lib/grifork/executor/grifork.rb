class Grifork::Executor::Grifork
  include Grifork::Executable

  # Run grifork command on remote node.
  #
  # 1. Create +Griforkfile+ and copy it to remote
  # 2. Login remote host by +ssh+ and execute +grifork+ command
  def run(node)
    c = config.grifork
    ssh node.host, %(test -d "#{c.workdir}" || mkdir -p "#{c.workdir}"), user: c.login
    rsync(node.host, config.griforkfile, "#{c.workdir}/Griforkfile")
    prepare_grifork_hosts_file_on_remote(node)
    ssh node.host, %(cd #{c.dir} && #{c.cmd} --file #{c.workdir}/Griforkfile --override-by #{c.workdir}/Griforkfile.hosts --on-remote), [], user: c.login
  end

  private

  def prepare_grifork_hosts_file_on_remote(node)
    c = config.grifork
    hostsfile = Tempfile.create('Griforkfile.hosts')
    hostsfile.write(<<-EOS)
      hosts #{node.all_descendant_nodes.map(&:host)}
    EOS
    hostsfile.flush
    rsync(node.host, hostsfile.path, "#{c.workdir}/Griforkfile.hosts")
    hostsfile.close
  end
end
