module Grifork::Executable
  include Grifork::Configured
  include Grifork::Loggable

  class CommandFailure < StandardError; end
  class SSHCommandFailure < StandardError; end

  # Execute shell command at localhost
  # @param cmd  [String] command
  # @param args [Array]  arguments
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

  # Execute +ssh+ with command to execute at remote host
  # @param host [String] hostname
  # @param cmd  [String] command
  # @param args [Array]  arguments
  def ssh(host, cmd, args = [])
    command = "#{cmd} #{args.shelljoin}"
    if config.dry_run?
      logger.info("[Dry-run] #ssh @#{host} #{config.ssh.options} | #{cmd} #{args}")
      return
    else
      logger.info("#ssh @#{host} #{config.ssh.options} | #{cmd} #{args}")
    end
    Net::SSH.start(host, nil, config.ssh.options) do |ssh|
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

  # Shorthand for +rsync+ command.
  # Sync contents to target host
  # @param host [String] Target hostname
  # @param from [String] Path to source file or directory
  # @param to   [String] Path to destination at remote host.
  #  If you omit this param, it will be the same with +from+ param
  def rsync(host, from, to = nil)
    to ||= from
    sh :rsync, [*config.rsync_opts, from, "#{host}:#{to}"]
  end

  # Shorthand for +rsync+ command run by +ssh+ to source host
  # Sync contents from source host to target host
  # @param src  [String] Source hostname to login by +ssh+
  # @param dst  [String] Target hostname
  # @param from [String] Path to source file or directory
  # @param to   [String] Path to destination at remote host.
  #  If you omit this param, it will be the same with +from+ param
  def rsync_remote(src, dst, from, to = nil)
    to ||= from
    ssh src, :rsync, [*config.rsync_opts, from, "#{dst}:#{to}"]
  end
end
