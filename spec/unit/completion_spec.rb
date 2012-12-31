require 'spec_helper'

require 'orchestrated'
require 'first'
require 'second'

describe Orchestrated::CompletionExpression do
  context 'Complete' do
    it 'should complete immediately' do
      First.any_instance.should_receive(:do_first_thing)
      First.new.orchestrated(Orchestrated::Complete.new).do_first_thing(12)
      DJ.work(1)
    end
    it 'should be the default' do
      First.any_instance.should_receive(:do_first_thing)
      First.new.orchestrated.do_first_thing(12)
      DJ.work(1)
    end
  end
  context 'Incomplete' do
    it 'should never complete' do
      First.any_instance.should_not_receive(:do_first_thing)
      First.new.orchestrated(Orchestrated::Incomplete.new).do_first_thing(12)
      DJ.work(1)
    end
  end
  context 'OrchestrationCompletion' do
    it 'should block second orchestration while first is incomplete' do
      Second.any_instance.should_not_receive(:do_second_thing)
      Second.new.orchestrated( First.new.orchestrated(Orchestrated::Incomplete.new).do_first_thing(3)).do_second_thing(4)
      DJ.work(2)
    end
    it 'should run second orchestration after first is complete' do
      Second.any_instance.should_receive(:do_second_thing)
      Second.new.orchestrated( First.new.orchestrated.do_first_thing(3)).do_second_thing(4)
      DJ.work(2)
    end
  end
  context 'FirstCompletion' do
    before(:each) do
      Second.new.orchestrated( Orchestrated::FirstCompletion.new <<
        First.new.orchestrated.do_first_thing(3) <<
        First.new.orchestrated.do_first_thing(4)
        ).do_second_thing(5)
    end
    it 'should enqueue the dependent orchestration as soon as the first prerequisite completes' do
      expect(DJ.job_count).to be(2)
      DJ.work(1)
      expect(DJ.job_count).to be(2)
    end
    it 'should run the dependent orchestration eventually' do
      Second.any_instance.should_receive(:do_second_thing).with(5)
      DJ.work(3)
    end
    it 'should skip dependents after the first one runs' do
      First.any_instance.should_not_receive(:do_first_thing).with(4)
      DJ.work(3)
    end
  end
  context 'LastCompletion' do
    before(:each) do
      Second.new.orchestrated( Orchestrated::LastCompletion.new <<
        First.new.orchestrated.do_first_thing(3) <<
        First.new.orchestrated.do_first_thing(4)
        ).do_second_thing(5)
    end
    it 'should not enqueue the dependent orchestration as soon as the first prerequisite completes' do
      expect(DJ.job_count).to be(2)
      DJ.work(1)
      expect(DJ.job_count).to be(1)
    end
    it 'should not run the dependent orchestration as soon as the first prerequisite completes' do
      Second.any_instance.should_not_receive(:do_second_thing)
      DJ.work(2)
    end
    it 'should run the dependent orchestration after all the prerequisite are complete' do
      Second.any_instance.should_receive(:do_second_thing)
      DJ.work(3)
    end
  end
end
