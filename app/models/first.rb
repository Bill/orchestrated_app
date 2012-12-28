require 'orchestrated'

class First < ActiveRecord::Base

  acts_as_orchestrated

  def do_first_thing(other_prime)
    5 * other_prime # 5 is a prime
  end

end
