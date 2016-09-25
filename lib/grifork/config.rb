class Grifork::Config
  attr :branches, :hosts, :log
  def initialize
    @branches = 4
    @log = OpenStruct.new(
      file:  'tmp/grifork.log',
      level: 'debug',
    ).freeze
    @hosts = (1..10).map { |i| Grifork::Host.new("host#{i}") }
  end
end
