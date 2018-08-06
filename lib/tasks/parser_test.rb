require 'open-uri'
require 'net/http'
require 'json'
require 'Nokogiri'

class Job
  attr_accessor :jobTitle, :companyLogoURL, :companyName, :jobDescription, :applyURL, :tags, :source

  def initialize(jobTitle, companyLogoURL, companyName, jobDescription, applyURL, tags, source)
    self.jobTitle = jobTitle
    self.companyLogoURL = companyLogoURL
    self.companyName = companyName.split(".").first
    self.jobDescription = jobDescription.split('Apply for this Job').first
    self.applyURL = applyURL
    self.tags = tags
    self.source = source
  end

  def to_s
    "#{self.jobTitle} - #{self.jobDescription}"
  end
end


module Parser
  def self.get_jobs_from_remoteok
    url = "https://remoteok.io/remote-jobs"
    page = Nokogiri::HTML(open(url))
    jobs = page.css("body table#jobsboard tr").to_a
    jobs.delete_at(0)

    parsed_jobs = []
    jobs.each_slice(2) do |array_data|
      begin
        data = array_data.first.css("td")

        begin
          logo_url = data[0].css("a").children.first.attributes["data-src"].text
        rescue
          logo_url = Parser.unwrap(data[0].css("a").text)
        end

        apply_url = Parser.unwrap("#{url}#{array_data.first.attributes["data-url"].text}")
        job_title = Parser.unwrap(data[1].css("a h2").text)
        company = Parser.unwrap(data[1].css("a h3").text)
        tags = Parser.unwrap(data[3].text.split("3>"))
        description = Parser.unwrap(array_data.last.text)

        parsed_job = Job.new(job_title, logo_url, company, description, apply_url, tags, 'remote-ok')
        parsed_jobs << parsed_job
      rescue
        next
      end
    end

    parsed_jobs
  end

  def self.get_jobs_from_landing_jobs
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

        job = Job.new(job_title, company_logo_url, company_name, job_description, apply_url, tags, 'landing-jobs')
        jobs << job
      end
      
      break if last_page
    end

    jobs
  end

  private

  def self.unwrap(value)
    begin
      value
    rescue
      ""
    end
  end
end

puts Parser.get_jobs_from_remoteok
