class Grifork::Task::Remote < Grifork::Task::Base
  # @todo Implement ssh
  def ssh(host, args)
    # Temporary dummy
    p "ssh is not implemented"
    p ["#{host.hostname}", args]
  end

  # @todo Implement rsync
  def rsync
  end
end
