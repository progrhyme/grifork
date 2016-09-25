class Grifork::Task
  attr :src, :dst
  include Grifork::Mixin::Loggable

  class CommandFailure < StandardError; end

  def initialize(type, &task)
    @type = type
    @task = task
  end

  def run(src, dst)
    @src = src
    @dst = dst
    instance_eval(&@task)
  end

  private

  def sh(command, args)
    logger.info("Run sh: #{command} #{args}")
    stat = Open3.popen3(command.to_s, *args) do |stdin, stdout, stderr, wait_thr|
      stdin.close
      stdout.each { |l| logger.info("[STDOUT] " + l.chomp) }
      stderr.each { |l| logger.warn("[STDERR] " + l.chomp) }
      wait_thr.value
    end

    unless stat.success?
      raise CommandFailure, "Failed to exec command! #{command} #{args}"
    end
  end

  # @todo Implement ssh
  def ssh(host, args)
    # Temporary dummy
    p "ssh is not implemented"
    p ["#{host.hostname}", args]
  end

  # @todo Implement rsync
  def rsync
  end

  # @todo Implement remote rsync
  def rsync_remote
  end
end
