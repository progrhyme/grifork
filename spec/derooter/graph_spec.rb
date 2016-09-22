require 'spec_helper'

describe Derooter::Graph do
  describe '.new' do
    let(:hosts) { [] }
    subject { Derooter::Graph.new(hosts) }
    it { expect(subject).to be_truthy }
  end
end
