require 'spec_helper'

require 'pathname'

describe Grifork::Graph do
  let(:config) { Grifork::Config.new(branches: 3) }
  before do
    Grifork.configure!(config)
  end

  describe '.new' do
    let(:hosts) { [] }
    subject { Grifork::Graph.new(hosts) }
    it { expect(subject).to be_truthy }
  end

  describe '#fork_tasks' do
    $fork_tasks_log = Pathname.new('tmp/graph_fork_tasks_spec.log')
    let(:config) do
      hosts      = 1.upto(10).map { |i| Grifork::Host.new("host#{i}") }
      local_task = Grifork::Task.new(:local) do
        sh "echo LOCAL #{src.hostname}:#{dst.hostname} >> #{$fork_tasks_log}", []
      end
      remote_task = Grifork::Task.new(:remote) do
        sh "echo REMOTE #{src.hostname}:#{dst.hostname} >> #{$fork_tasks_log}", []
      end
      Grifork::Config.new(
        branches:    2,
        hosts:       hosts,
        log:         Grifork::Config::Log.new({level: 'warn'}),
        local_task:  local_task,
        remote_task: remote_task,
      )
    end
    let(:graph) { Grifork::Graph.new(config.hosts) }

    after do
      File.unlink($fork_tasks_log)
    end

    subject { graph.fork_tasks }

    it 'Run tasks through the whole tree' do
      expect { subject }.not_to raise_error
      outputs = File.read($fork_tasks_log).each_line.map(&:chomp)
      expected = 1.upto(2).map { |i| "LOCAL localhost:host#{i}" }
      [[1, [3, 4]], [2, [5, 6]], [3, [7, 8]], [4, [9, 10]]].each do |list|
        j = list[0]
        list[1].each do |k|
          expected << "REMOTE host#{j}:host#{k}"
        end
      end
      expect(outputs).to match_array(expected)
    end
  end

  describe '#add_node_by_host' do
    let(:node_num) { 1 }
    before :each do
      @graph = Grifork::Graph.new
      node_num.times do |idx|
        @graph.add_node_by_host(Grifork::Host.new("host#{idx}"))
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
