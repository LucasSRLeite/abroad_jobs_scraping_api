class JobsController < ApplicationController
  def index
    jobs = Array.new
    
    jobs << Parser.get_jobs_from_remoteok
    jobs << Parser.get_jobs_from_landing_jobs
    jobs << Parser.get_jobs_from_cryptojobs
    
    render json: jobs
  end
end
