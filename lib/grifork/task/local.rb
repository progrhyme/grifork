class Grifork::Task::Local < Grifork::Task::Base
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
end
