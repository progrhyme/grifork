class Grifork::Task::Local < Grifork::Task::Base
  def sh(*args)
    unless args[0]
      raise CommandFailure, ":sh called with no argument!"
    end
    command = args.shift.to_s + ' '
    command << args.shelljoin
    logger.info("Run sh: #{command}")
    stat = Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
      stdin.close
      stdout.each { |l| logger.info("[STDOUT] " + l.chomp) }
      stderr.each { |l| logger.warn("[STDERR] " + l.chomp) }
      wait_thr.value
    end

    unless stat.success?
      raise CommandFailure, "Failed to exec command! #{command}"
    end
  end
end
