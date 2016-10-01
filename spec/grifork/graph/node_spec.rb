require 'spec_helper'

describe Grifork::Graph::Node do
  def gen_node
    Grifork::Graph::Node.new('localhost')
  end

  before :context do
    Grifork.configure!(Grifork::Config.new(branches: 3))
  end

  after :each do
    Grifork::Graph::Node.instance_variable_set('@count', 0)
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

  describe '#all_descendant_nodes' do
    let(:graph) do
      graph = Grifork::Graph.new
      20.times do |idx|
        graph.add_node_by_host("host#{idx}")
      end
      graph
    end

    it 'Return all descendant nodes by depth-first search' do
      root = graph.root
      expect(root.all_descendant_nodes.map(&:index)).to eq (1..20).to_a
      expect(root.children[0].all_descendant_nodes.map(&:index)).to eq [4, 5, 6, 13, 14, 15, 16, 17, 18, 19, 20]
    end
  end
end
