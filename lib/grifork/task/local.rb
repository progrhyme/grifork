class Grifork::Task::Local < Grifork::Task::Base
  def sh(*args)
    command = args.shelljoin
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
