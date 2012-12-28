module Orchestrated

  class OrchestratingWrapper < Ick::Wrapper
    def initialize(value, prerequisite)
      @prerequisite = prerequisite
      super(value)
    end
    def __rewrap__(new_value)
      self.__class.new(new_value, @prerequisite) #contagious
    end
    def __invoke__(sym, *args, &block)
      # TODO: set up database stuff to record guard conditions
      # TODO: move this delay.send to run after prerequisite is met
      @value.delay.send( sym, *args, &block) # queue work
      # TBD: should I evaluate all db guard conditions here poll for it elsewhere?
      @prerequisite
    end
  end

  class Orchestrated < Ick::Wrap
    def invoke(value, prerequisite=Complete.new, &proc)
      invoke_wrapped(value, OrchestratingWrapper, prerequisite, &proc)
    end
    evaluates_in_calling_environment and returns_result
  end

end
