class Grifork::Task
  attr :src, :dst
  include Grifork::Mixin::Loggable

  class CommandFailure < StandardError; end
  class SSHCommandFailure < StandardError; end

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

  def sh(cmd, args)
    logger.info("#sh start - #{cmd} #{args}")
    stat = Open3.popen3(cmd.to_s, *args) do |stdin, stdout, stderr, wait_thr|
      stdin.close
      stdout.each { |l| logger.info("#sh [out] #{l.chomp}") }
      stderr.each { |l| logger.warn("#sh [err] #{l.chomp}") }
      wait_thr.value
    end

    unless stat.success?
      raise CommandFailure, "Failed to exec command! #{cmd} #{args}"
    end
  end

  def ssh(host, cmd, args)
    command = "#{cmd} #{args.shelljoin}"
    logger.info("#ssh start - to: #{host.hostname}, command: #{cmd} #{args}")
    Net::SSH.start(host.hostname) do |ssh|
      channel = ssh.open_channel do |ch|
        ch.exec(command) do |ch, success|
          unless success
            raise SSHCommandFailure, "Failed to exec ssh command! on: #{host.hostname} command: #{cmd} #{args}"
          end

          ch.on_data          { |c, d|    logger.info("#ssh [out] #{d.chomp}") }
          ch.on_extended_data { |c, t, d| logger.warn("#ssh [err] #{d.chomp}") }
          ch.on_close         { logger.debug("#ssh end.") }
        end
      end
      channel.wait
    end
  end

  # @todo Implement rsync
  def rsync
  end

  # @todo Implement remote rsync
  def rsync_remote
  end
end
