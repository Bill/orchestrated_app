module Orchestrated
  class ::Object
    class << self
      def acts_as_orchestrated
        Orchestrated.belongs_to self # define "orchestrated instance method"
      end
    end
  end
end
