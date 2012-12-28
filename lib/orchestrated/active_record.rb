module Orchestrated

  module ActiveRecordExtensions
  end

  class ActiveRecord::Base
    class << self
      def acts_as_orchestrated
        include ActiveRecordExtensions
        Orchestrated.belongs_to self # define "orchestrated instance method"
      end
    end
  end

end
