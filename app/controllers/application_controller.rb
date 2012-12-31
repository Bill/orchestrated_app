class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
    Second.new.orchestrated(First.new.orchestrated.do_first_thing(2)).do_second_thing(3)
  end
end
