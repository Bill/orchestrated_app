module Orchestrated
  class MessageDelivery
    attr_accessor :orchestrated, :method_name, :args, :orchestration_id

    def initialize(orchestrated, method_name, args, orchestration_id)
      self.orchestrated = orchestrated
      self.method_name  = method_name
      self.args         = args
      self.orchestration_id = orchestration_id
    end

    def perform
      orchestrated.send(method_name, *args) if orchestrated

      orchestration = Orchestration.find(self.orchestration_id)
      orchestration.message_delivery_succeeded
    end

  end
end
