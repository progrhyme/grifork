require 'rspec'
require 'grifork'

class Test
  class FakeConfig
    attr_accessor :jobs, :hosts
    def initialize(jobs: 4, hosts: 10)
      @jobs = jobs
      @hosts = (1..hosts).map { Grifork::Host.new }
    end
  end
end

Grifork.configure!(Test::FakeConfig.new)
