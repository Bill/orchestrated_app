module Orchestrated
  # just like a PerformableMethod but we want to intercept delivery
  # of the delayed message and do so set-up and tear-down
  class MessageDelivery < Delayed::PerformableMethod
    attr_accessor :orchestration_id

    def initialize(orchestrated, method_name, args, orchestration_id)
      super(orchestrated, method_name, args)
      self.orchestration_id = orchestration_id
    end

    def perform
      super
      orchestration = Orchestration.find(self.orchestration_id)
      orchestration.message_delivery_succeeded
    end

  end
end
