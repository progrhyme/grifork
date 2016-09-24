require 'rspec'
require 'grifork'

class Test
  class FakeConfig
    attr_accessor :branches, :hosts
    def initialize(branches: 4, hosts: 10)
      @branches = branches
      @hosts = (1..hosts).map { Grifork::Host.new }
    end
  end
end

Grifork.configure!(Test::FakeConfig.new)
