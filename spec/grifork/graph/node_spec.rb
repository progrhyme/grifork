require 'spec_helper'

describe Grifork::Graph::Node do
  def gen_node
    Grifork::Graph::Node.new('localhost')
  end

  before :context do
    Grifork.configure!(Grifork::Config.new(branches: 3))
  end

  describe '#acceptable?' do
    before :each do
      @parent = gen_node
    end
    subject { @parent.acceptable? }

    context 'With no children' do
      it { expect(subject).to be true }
    end

    context 'With max children' do
      before :each do
        3.times do
          @parent.add_child(gen_node)
        end
      end
      it { expect(subject).to be false }
    end
  end
end
