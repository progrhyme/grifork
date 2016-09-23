require 'spec_helper'

describe Grifork::Graph::Node do
  before :context do
    Grifork.configure!(Test::FakeConfig.new(jobs: 3))
  end

  describe '#acceptable?' do
    before :each do
      @parent = Grifork::Graph::Node.new(Grifork::Host.new)
    end
    subject { @parent.acceptable? }

    context 'With no children' do
      it { expect(subject).to be true }
    end

    context 'With max children' do
      before :each do
        3.times do
          @parent.add_child(Grifork::Host.new.to_node)
        end
      end
      it { expect(subject).to be false }
    end
  end
end
