require 'spec_helper'

require 'tempfile'

describe Grifork::DSL do
  describe '.load_file' do
    let(:content)   { nil   }
    let(:on_remote) { false }
    before do
      @dsl = Tempfile.new('dsl')
      File.write(@dsl.path, content)
    end

    after do
      File.unlink(@dsl.path)
    end

    subject { Grifork::DSL.load_file(@dsl.path, on_remote: on_remote) }

    context 'With valid DSL' do
      let(:content) do
        <<-EODSL
          branches 2
          log file: 'path/to/grifork.log'
          hosts ['web1', '192.168.1.1']
          local { p :local }
          remote { p :remote }
        EODSL
      end

      it 'Can load config' do
        expect { subject }.not_to raise_error
        dsl = subject
        expect(dsl).to be_an_instance_of(Grifork::DSL)
        config = dsl.instance_variable_get('@config')
        expect(config[:branches]).to eq 2
        expect(config[:log]).to be_an_instance_of(Grifork::Config::Log)
        expect(config[:hosts].size).to eq 2
        expect(config[:local_task]).to be_truthy
        expect(config[:remote_task]).to be_truthy
      end

      context 'With on_remote: true argument' do
        let(:on_remote) { true }

        it 'Load remote task as local' do
          expect { subject }.not_to raise_error
          dsl = subject
          expect(dsl).to be_an_instance_of(Grifork::DSL)
          config = dsl.instance_variable_get('@config')
          expect(config[:branches]).to eq 2
          expect(config[:log]).to be_an_instance_of(Grifork::Config::Log)
          expect(config[:hosts].size).to eq 2
          expect(config[:remote_task]).to be nil
          ret = config[:local_task].run(:a, :b)
          expect(ret).to be :remote
        end
      end
    end

    context 'With invalid DSL' do
      let(:content) do
        <<-EODSL
          no_such_method :xxx
        EODSL
      end

      it 'Raise error' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#load_and_merge_config_by!' do
    let(:content) { nil }

    before do
      @one = Grifork::DSL.new(false)
      @one.mode(:standalone)
      @one.branches(2)
      @one.hosts([])
      @dslfile = Tempfile.new('dslfile')
      File.write(@dslfile.path, content)
    end

    after do
      File.unlink(@dslfile.path)
    end

    subject { @one.load_and_merge_config_by!(@dslfile.path) }

    context 'When another DSL has different params' do
      let(:content) do
        <<-EODSL
          mode :grifork
          hosts %w(alpha beta gamma)
        EODSL
      end

      it 'Params are overridden' do
        subject
        expect(@one.config[:mode]).to eq :grifork
        expect(@one.config[:branches]).to eq 2
        expect(@one.config[:hosts].size).to eq 3
      end
    end

  end
end
