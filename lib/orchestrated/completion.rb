module Orchestrated
  # a little ditty to support the completion algebra
  # a composite!
  # Completion is used as a prerequisite (prerequisites) for message passing
  class CompletionExpression < ActiveRecord::Base
    # I'd like to make this abstract, but Rails gets confused if I do
    # self.abstract_class = true
    def complete?; throw "subclass must override!";end
  end
  class Complete < CompletionExpression
    def complete?; true; end
  end
  class Incomplete < CompletionExpression
    def complete?; false; end
  end
  class CompositeCompletion < CompletionExpression
    # self.abstract_class = true
    has_many :composited_completions
    has_many :completion_expressions, :through => :composited_completions, :source => :completion_expression
    def <<(c)
      completion_expressions << c
      self
    end
    def +(c); self << c; end # synonym
  end
  class LastCompletion < CompositeCompletion
    def complete?; completion_expressions.all?(&:complete?); end
  end
  class FirstCompletion < CompositeCompletion
    def complete?; completion_expressions.any?(&:complete?); end
  end
  class OrchestrationCompletion < CompletionExpression
    # Arguably, it is "bad" to make this class derive
    # from CompletionExpression since doing so introduces
    # the orchestration_id into the table (that constitutes
    # denormalization since no other types need that field).
    # The alternative is that we have to do difficult-to-
    # understand joins when computing dependents at runtime.
    belongs_to :orchestration
    validates_presence_of :orchestration_id
    delegate :complete?, :to => :orchestration
  end
  class CompositedCompletion < ActiveRecord::Base
    belongs_to :composite_completion
    belongs_to :completion_expression
  end
end
