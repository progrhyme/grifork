require 'spec_helper'

describe Grifork::Graph do
  before :context do
    Grifork.configure!(Test::FakeConfig.new(jobs: 3))
  end

  describe '.new' do
    let(:hosts) { [] }
    subject { Grifork::Graph.new(hosts) }
    it { expect(subject).to be_truthy }
  end

  describe '#add_node' do
    let(:node_num) { 1 }
    before :each do
      @graph = Grifork::Graph.new
      node_num.times do |idx|
        @graph.add_node(Grifork::Host.new("host#{idx}").to_node)
      end
    end

    context 'When just initialized' do
      it 'Added as child of @root' do
        expect(@graph.nodes).to be 2
        expect(@graph.depth).to be 1
        expect(@graph.root.children.size).to be 1
      end
    end

    context 'After @root has got unacceptable' do
      let(:node_num) { 4 }

      it 'Added as child of first child of @root' do
        expect(@graph.nodes).to be 5
        expect(@graph.depth).to be 2
        expect(@graph.root.children.size).to be 3
        expect(@graph.root.children[0].children.size).to be 1
      end
    end

    context 'After first child of @root has got unacceptable' do
      let(:node_num) { 7 }

      it 'Added as child of second child of @root' do
        expect(@graph.nodes).to be 8
        expect(@graph.depth).to be 2
        expect(@graph.root.children.size).to be 3
        expect(@graph.root.children[0].children.size).to be 3
        expect(@graph.root.children[1].children.size).to be 1
      end
    end

    context 'After all children of @root have got unacceptable' do
      let(:node_num) { 13 }

      it 'Added as child of first child of first child of @root' do
        expect(@graph.nodes).to be 14
        expect(@graph.depth).to be 3
        [@graph.root].concat(@graph.root.children).each do |node|
          expect(node.children.size).to be 3
        end
        expect(@graph.root.children[0].children[0].children.size).to be 1
      end
    end

    context 'When 80 nodes added' do
      let(:node_num) { 3 + 9 + 27 + 81 }

      it 'Complete 3-depth tree' do
        expect(@graph.nodes).to be 121
        expect(@graph.depth).to be 4
        expect(@graph.root.children.size).to be 3
        @graph.root.children.each do |node|
          expect(node.children.size).to be 3
          node.children.each do |child|
            expect(child.children.size).to be 3
            child.children.each do |gc|
              expect(gc.children.size).to be 3
              gc.children.each do |ggc|
                expect(ggc.children.size).to be 0
              end
            end
          end
        end
      end
    end
  end
end
