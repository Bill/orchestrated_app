require 'spec_helper'

require 'orchestrated'
require 'first'
require 'second'

describe Orchestrated do
  context 'initializing' do
    it 'should not define orchestrated on Object' do
      expect(Object.public_method_defined?(:orchestrated)).to be_false
    end
    it 'should not define orchestrated on ActiveRecord::Base' do
      expect(ActiveRecord::Base.public_method_defined?(:orchestrated)).to be_false
    end
    it 'should define orchestrated on First' do
      expect(First.public_method_defined?(:orchestrated)).to be_true
    end
  end
  context 'a new orchestrated object' do
    let(:f){First.new}
    context 'responding to messages without orchestration' do
      let(:result){f.do_first_thing(2)} # 2 is a prime number
      it 'should immediately invoke a non-orchestrated method and return correct result' do
        expect(result).to eq(5 * 2)
      end
    end
    context 'orchestrating with no precursors' do
      before(:each){@result = f.orchestrated.do_first_thing(2)}
      after(:each){DJ.clear_all_jobs}
      it 'should not immediately invoke an orchestrated method' do
        First.any_instance.should_not_receive(:do_first_thing)
      end
      it 'should return an Orchestration object' do
        expect(@result).to be_kind_of(Orchestrated::CompletionExpression)
      end
      it 'should enqueue a job' do
        expect(DJ.job_count).to eq(1)
      end
      context 'after work_off' do
        it 'should invoke the orchestrated method' do
          First.any_instance.should_receive(:do_first_thing)
          DJ.work
        end
        it 'should pass a parameter to the orchestrated object' do
          First.any_instance.should_receive(:do_first_thing).with(2)
          DJ.work
        end
      end
    end
    context 'orchestrating with a simple prerequisite' do
      let(:s) {Second.new}
      before(:each){
        a = f
        b = a.orchestrated
        c = b.do_first_thing(2)
        d = s
        e = d.orchestrated(c)
        g = e.do_second_thing(3)
        @result = g
      # @result = s.orchestrated( f.orchestrated.do_first_thing(2)).do_second_thing(3)
      } # 3 is a prime number
      context 'after completing the prerequisite' do
        before(:each) do
          DJ.work # this completes the first prerequisite (see "orchestrating with no precursors after work_off")
        end
        context 'next work_off' do
          it 'should invoke the orchestrated method' do
            Second.any_instance.should_receive(:do_second_thing).exactly(1).times
            DJ.work
          end
          it 'should pass a parameter to the orchestrated object' do
            Second.any_instance.should_receive(:do_second_thing).with(3)
            DJ.work
          end
        end
      end
    end
  end
end
