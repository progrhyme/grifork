class Derooter::Config
  attr :jobs, :hosts
  def initialize
    @jobs = 4
    @hosts = (1..10).map { Derooter::Host.new }
  end
end
