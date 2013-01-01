require 'spec_helper'

require 'orchestrated'
require 'first'

shared_examples_for 'cancelled' do
  before(:each) do
    @orch.cancel
  end
  it 'should be in the "cancelled" state' do
    expect(@orch.orchestration.cancelled?).to be(true)
  end
  it 'should never subsequently deliver the orchestrated message' do
    First.any_instance.should_not_receive(:do_first_thing)
    DJ.work(1)
  end
end

describe 'cancellation' do
  context 'an orchestration' do
    before(:each) do
      @orch = First.new.orchestrated.do_first_thing(1)
    end
    context 'that is ready' do
      it_should_behave_like 'cancelled'
    end
    context 'that is succeeded' do
      before(:each) do
        @orch.orchestration.state = 'succeeded'
      end
      it_should_behave_like 'cancelled'
    end
    context 'that is failed' do
      before(:each) do
        @orch.orchestration.state = 'failed'
      end
      it_should_behave_like 'cancelled'
    end
    context 'that is cancelled' do
      before(:each) do
        @orch.orchestration.state = 'cancelled'
      end
      it_should_behave_like 'cancelled'
    end
  end

end
