# facade for controlling delayed_job
module DJ
  module_function

  def job_count
    Delayed::Job.count
  end
  def work(num=1)
    Delayed::Worker.new.work_off(num)
  end
  def clear_all_jobs
    Delayed::Job.delete_all
  end
end
