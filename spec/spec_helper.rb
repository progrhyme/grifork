require 'rspec'
require 'derooter'

class Test
  class FakeConfig
    attr_accessor :jobs, :hosts
    def initialize(jobs: 4, hosts: 10)
      @jobs = jobs
      @hosts = (1..hosts).map { Derooter::Host.new }
    end
  end
end

Derooter.configure!(Test::FakeConfig.new)
