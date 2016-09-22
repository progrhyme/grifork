class Derooter::Config
  attr :jobs, :hosts
  def initialize
    @jobs = 4
    @hosts = (1..100).map { |i| Derooter::Host.new("host#{i}") }
  end
end
