require 'spec_helper'

describe Derooter::Graph::Node do
  before :context do
    Derooter.configure!(Test::FakeConfig.new(jobs: 3))
  end

  describe '#acceptable?' do
    before :each do
      @parent = Derooter::Graph::Node.new(Derooter::Host.new)
    end
    subject { @parent.acceptable? }

    context 'With no children' do
      it { expect(subject).to be true }
    end

    context 'With max children' do
      before :each do
        3.times do
          @parent.add_child(Derooter::Host.new.to_node)
        end
      end
      it { expect(subject).to be false }
    end
  end
end
