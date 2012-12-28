module Orchestrated
  # a little ditty to support the completion algebra
  # a composite!
  # Completion is used as a prerequisite (prerequisites) for message passing
  class Completion
    def orchestration_complete?;end
  end
  class Complete < Completion
    def orchestration_complete?; true; end
  end
  class Incomplete < Completion
    def orchestration_complete?; false; end
  end
  class SimpleCompletion
    attr_accessor :ar
    delegate :orchestration_complete?, :to => :ar
    def +(c); CompositeCompletion.new << self << c; end
    def initialize(ar); @ar = ar; end
  end
  class CompositeCompletion
    attr_accessor :conjunctions
    def initialize; @conjunctions = []; end
    def <<(c); @conjunctions << c; end
    def +(c); self << c; end # synonym
    def orchestration_complete?; @completions.all(&:orchestration_complete?); end
  end
end
