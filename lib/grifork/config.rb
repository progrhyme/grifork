class Grifork::Config
  attr :branches, :hosts
  def initialize
    @branches = 4
    @hosts = (1..100).map { |i| Grifork::Host.new("host#{i}") }
  end
end
