require 'spec_helper'

describe Orchestrated do
  context 'initializing' do
    it 'should not define orchestrated on Object' do
      expect(Object.public_method_defined?(:orchestrated)).to be_false
    end
    it 'should not define orchestrated on ActiveRecord::Base' do
      expect(ActiveRecord::Base.public_method_defined?(:orchestrated)).to be_false
    end
    it 'should define orchestrated on First class' do
      expect(First.public_method_defined?(:orchestrated)).to be_true
    end
  end
  context 'a new orchestrated object' do
    let(:f){First.create}
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
        expect(@result).to_not eq(5 * 2)
      end
      it 'should return a Completion object' do
        expect(@result).to be_kind_of(Orchestrated::Completion)
      end
      it 'should enqueue a job' do
        expect(DJ.job_count).to eq(1)
      end
      context 'after work_off' do
        it 'should instantiate the orchestrated object' do
          expect_deswizzle(First) do |f2|
            expect(f2.id).to be_equal(f.id)
          end
          DJ.work
        end
        it 'should invoke the orchestrated method' do
          expect_deswizzle(First) do |f2|
            f2.should_receive(:do_first_thing).exactly(1).times
          end
          DJ.work
        end
        it 'should pass a parameter to the orchestrated object' do
          expect_deswizzle(First) do |f2|
            f2.should_receive(:do_first_thing).with(2)
          end
          DJ.work
        end
      end
    end
    context 'orchestrating with a simple prerequisite' do
      let(:s) {Second.create}
      before(:each){@result = s.orchestrated( f.orchestrated.do_first_thing(2)).do_second_thing(3)} # 3 is a prime number
      context 'after completing the prerequisite' do
        before(:each) do
          DJ.work # this completes the first prerequisite (see "orchestrating with no precursors after work_off")
        end
        context 'next work_off' do
          it 'should instantiate the orchestrated object' do
            expect_deswizzle(Second) do |s2|
              expect(s2.id).to be_equal(s.id)
            end
            DJ.work
          end
          # TODO: OR maybe verify that the message has already been delivered
        end
      end
    end
    # context 'with a precursor' do
    #   let(:s){Second.create}
    #     it 'should delay invocation of an orchestrated method' do
    #       expect(s.orchestrated(f.completion).do_second_thing).to be_nil
    #     end
    # end
  end
end
