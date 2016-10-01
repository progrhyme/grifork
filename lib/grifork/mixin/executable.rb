module Grifork::Executable
  include Grifork::Loggable

  class CommandFailure < StandardError; end
  class SSHCommandFailure < StandardError; end

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

          ch.on_data do |c, d|
            d.each_line { |l| logger.info("#ssh [out] #{l.chomp}") }
          end
          ch.on_extended_data do |c, t, d|
            d.each_line { |l| logger.warn("#ssh [err] #{l.chomp}") }
          end
          ch.on_close { logger.debug("#ssh end.") }
        end
      end
      channel.wait
    end
  end

  def rsync(from, to = nil)
    to ||= from
    sh :rsync, [*rsync_opts, from, "#{dst.hostname}:#{to}"]
  end

  # @todo Implement remote rsync
  def rsync_remote(from, to = nil)
    to ||= from
    ssh src, :rsync, [*rsync_opts, from, "#{dst.hostname}:#{to}"]
  end

  def rsync_opts
    %w(-avzc --delete)
  end
end
