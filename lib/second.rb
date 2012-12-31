class Second

  acts_as_orchestrated

  def do_second_thing(other_prime)
    puts "DOING SECOND THING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    7 * other_prime # 7 is a prime
  end

end
