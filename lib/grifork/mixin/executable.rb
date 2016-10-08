module Grifork::Executable
  include Grifork::Configured
  include Grifork::Loggable

  class CommandFailure < StandardError; end
  class SSHCommandFailure < StandardError; end

  def sh(cmd, args = [])
    if config.dry_run?
      logger.info("[Dry-run] #sh | #{cmd} #{args}")
      return
    else
      logger.info("#sh | #{cmd} #{args}")
    end
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

  def ssh(host, cmd, args = [], user: nil)
    command = "#{cmd} #{args.shelljoin}"
    if config.dry_run?
      logger.info("[Dry-run] #ssh #{user}@#{host} | #{cmd} #{args}")
      return
    else
      logger.info("#ssh #{user}@#{host} | #{cmd} #{args}")
    end
    ssh_args = [host]
    ssh_args << user if user
    Net::SSH.start(*ssh_args) do |ssh|
      channel = ssh.open_channel do |ch|
        ch.exec(command) do |ch, success|
          unless success
            raise SSHCommandFailure, "Failed to exec ssh command! - #{user}@#{host} | #{cmd} #{args}"
          end

          ch.on_data do |c, d|
            d.each_line { |l| logger.info("#ssh @#{host} [out] #{l.chomp}") }
          end
          ch.on_extended_data do |c, t, d|
            d.each_line { |l| logger.warn("#ssh @#{host} [err] #{l.chomp}") }
          end
          ch.on_close { logger.debug("#ssh @#{host} end.") }
        end
      end
      channel.wait
    end
  end

  def rsync(from, to = nil)
    to ||= from
    sh :rsync, [*rsync_opts, from, "#{dst}:#{to}"]
  end

  def rsync_remote(from, to = nil, user: nil)
    to ||= from
    ssh src, :rsync, [*rsync_opts, from, "#{dst}:#{to}"], user: user
  end

  def rsync_opts
    %w(-avzc --delete)
  end
end
