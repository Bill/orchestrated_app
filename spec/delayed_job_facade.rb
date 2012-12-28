# facade for controlling delayed_job
module DJ
  module_function

  def job_count
    Delayed::Job.count
  end
  def work
    Delayed::Worker.new.work_off
  end
  def clear_all_jobs
    Delayed::Job.delete_all
  end
end
