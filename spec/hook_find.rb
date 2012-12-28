module HookFind
  module ClassMethods
    def found_instance(an_instance)
      # this method's purpose is to allow hooking in rspec
      an_instance
    end
  end
  def self.included(other)
    other.extend ClassMethods
    other.after_find :found
  end
  private # instrumentation
  def found(*args)
    self.class.found_instance(self)
  end
end

[First, Second].each do |c|
  c.instance_eval { include HookFind }
end
