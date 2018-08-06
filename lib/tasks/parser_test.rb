require 'open-uri'
require 'net/http'
require 'json'
require 'nokogiri'
require 'byebug'

class Job
  attr_accessor :jobTitle, :companyLogoURL, :companyName, :jobDescription, :applyURL, :tags, :source

  def initialize(jobTitle, companyLogoURL, companyName, jobDescription, applyURL, tags, source)
    self.jobTitle = jobTitle
    self.companyLogoURL = companyLogoURL
    self.companyName = companyName.split(".").first
    self.jobDescription = jobDescription#.split('Apply for this Job').first
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
      # begin
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
        description = ""
        desc_data = array_data.last.css('div.description')
        desc_data.each do |desc|
          byebug
          puts "[RAW] -> #{desc}"
          puts "[PARSED] -> #{desc.css('div')}"
          puts
        end
        description = Parser.unwrap(array_data.last.css('div.description p'))
        # puts "--> #{description}"
        parsed_job = Job.new(job_title, logo_url, company, description, apply_url, tags, 'remote-ok')
        parsed_jobs << parsed_job
      # rescue
      #   next
      # end
    end

    parsed_jobs
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
