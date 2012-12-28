module SpecHelperMethods
  # lets us set up expectations on deswizzled ActiveRecords
  def expect_deswizzle(clazz, &block)
    # http://stackoverflow.com/questions/5320292/expect-method-call-and-proxy-to-original-method-with-rspec
    original = clazz.method(:found_instance)
    clazz.should_receive(:found_instance) do |*args|
      original.call(*args).tap do |deswizzled|
        block.call(deswizzled)
      end
    end.at_least(:once)
    expect(original).to_not be(clazz.method(:found_instance))
  end
end
