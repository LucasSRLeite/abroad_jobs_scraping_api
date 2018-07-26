class JobsController < ApplicationController
  def index
    jobs = Parser.get_jobs_from_remoteok
    
    render json: jobs
  end
end
