class Grifork::Config
  attr :jobs, :hosts
  def initialize
    @jobs = 4
    @hosts = (1..100).map { |i| Grifork::Host.new("host#{i}") }
  end
end
