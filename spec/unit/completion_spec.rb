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
      DJ.work
    end
  end
  context 'OrchestrationCompletion' do
    it 'should block second orchestration while first is incomplete' do
      Second.any_instance.should_not_receive(:do_second_thing)
      Second.new.orchestrated( First.new.orchestrated(Orchestrated::Incomplete.new).do_first_thing(3)).do_second_thing(4)
      DJ.work
    end
    it 'should run second orchestration after first is complete' do
      Second.any_instance.should_receive(:do_second_thing)
      Second.new.orchestrated( First.new.orchestrated.do_first_thing(3)).do_second_thing(4)
      DJ.work(2)
    end
  end
  context 'FirstCompletion' do
    it 'should run the dependent orchestration as soon as the first prerequisite completes' do
      First.any_instance.should_receive(:do_first_thing).with(3)
      Second.any_instance.should_receive(:do_second_thing).with(5)
      Second.new.orchestrated( Orchestrated::FirstCompletion.new <<
        First.new.orchestrated.do_first_thing(3) <<
        First.new.orchestrated.do_first_thing(4)
        ).do_second_thing(5)
      DJ.work(2)
    end
    it 'should skip dependents after the first one runs' do
      First.any_instance.should_not_receive(:do_first_thing).with(4)
      Second.new.orchestrated( Orchestrated::FirstCompletion.new <<
        First.new.orchestrated.do_first_thing(3) <<
        First.new.orchestrated.do_first_thing(4)
        ).do_second_thing(5)
      DJ.work
    end
  end
  context 'LastCompletion' do
    it 'should not run the dependent orchestration as soon as the first prerequisite completes' do
      First.any_instance.should_receive(:do_first_thing).with(3)
      Second.any_instance.should_not_receive(:do_second_thing)
      Second.new.orchestrated( Orchestrated::LastCompletion.new <<
        First.new.orchestrated.do_first_thing(3) <<
        First.new.orchestrated.do_first_thing(4)
        ).do_second_thing(5)
      DJ.work(2)
    end
    it 'should run the dependent orchestration after all the prerequisite are complete' do
      First.any_instance.should_receive(:do_first_thing).with(3)
      First.any_instance.should_receive(:do_first_thing).with(4)
      Second.any_instance.should_receive(:do_second_thing)
      Second.new.orchestrated( Orchestrated::LastCompletion.new <<
        First.new.orchestrated.do_first_thing(3) <<
        First.new.orchestrated.do_first_thing(4)
        ).do_second_thing(5)
      DJ.work(3)
    end
  end
end
