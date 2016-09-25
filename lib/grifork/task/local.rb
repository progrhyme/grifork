class Grifork::Task::Local < Grifork::Task::Base
  def sh(*args)
    command = args.join(' ')
    stat = Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
      stdin.close
      stdout.each { |l| logger.info(l) }
      stderr.each { |l| logger.warn(l) }
      wait_thr.value
    end

    unless stat.success?
      raise CommandFailure, "Failed to exec command! #{command}"
    end
  end
end
