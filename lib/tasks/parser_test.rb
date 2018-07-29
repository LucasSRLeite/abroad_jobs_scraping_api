require 'open-uri'
require 'net/http'
require 'json'

class Job
  attr_accessor :jobTitle, :companyLogoURL, :companyName, :jobDescription, :applyURL, :tags, :source

  def initialize(jobTitle, companyLogoURL, companyName, jobDescription, applyURL, tags, source)
    self.jobTitle = jobTitle
    self.companyLogoURL = companyLogoURL
    self.companyName = companyName.split(".").first
    self.jobDescription = jobDescription.force_encoding("ISO-8859-1").encode("UTF-8")
    self.applyURL = applyURL
    self.tags = tags
    self.source = source
  end

  def tags
    "tags => [#{@tags.each {|tag| tag}}]"
  end

  def to_s
    "#{self.jobTitle} - #{self.companyName} - #{self.tags}"
  end
end


def get_jobs_from_landing_jobs
  jobs = Array.new

  path = "https://landing.jobs/jobs/search.json"
  page = 1
  loop do
    url = "#{path}?page=#{page}"
    page += 1

    response = Net::HTTP.get(URI(url))
    json = JSON.parse(response)

    last_page = json['last_page?']

    array_jobs_data = json['offers']
    array_jobs_data.each do |job_data|
      job_title = job_data['title']
      company_logo_url = job_data['company_logo_url']
      company_name = job_data['company_name']
      job_description = ""
      apply_url = job_data['url']
      
      tags = Array.new
      skills_data = job_data['skills']
      skills_data.each do |skill_data|
        tags << skill_data['name']
      end

      job = Job.new(job_title, company_logo_url, company_name, job_description, apply_url, tags)
      jobs << job
    end
    print '.'
    break if last_page
  end

  jobs
end

puts get_jobs_from_landing_jobs