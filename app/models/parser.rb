require 'open-uri'

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
          logo_url = data[0].children[1].children[1].values[3]
          logo_url = data[0].css("a").children.first.attributes["data-src"].text.strip if logo_url.nil?
        rescue
          logo_url = Parser.unwrap(data[0].css("a").text).strip
        end

        # ...
        apply_url = Parser.unwrap("#{url}#{array_data.first.attributes["data-url"].text}").strip
        job_title = Parser.unwrap(data[1].css("a h2").text).strip
        company = Parser.unwrap(data[1].css("a h3").text).strip
        tags = Parser.unwrap(data[3].text.split("\n")).map { |e| e.strip }.reject { |e| e.empty? || e == "digital nomad" }
        description = array_data.last.css('div.description div').to_s.gsub("<div class=\"markdown\">\n", "").gsub('</div>', "").strip
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

  def self.get_jobs_from_cryptojobs
    jobs = Array.new

    url = "https://cryptojobslist.com/job/filter?remote=true"

    response = Net::HTTP.get(URI(url))
    json = JSON.parse(response)
    json.each do |job_data|
      title = job_data["jobTitle"]
      company_logo_url = job_data["companyLogo"]
      company_name = job_data["companyName"]
      description = job_data["jobDescription"]
      apply_url = job_data["canonicalURL"]
      tags = Array.new
      category = job_data["category"]
      tags << category unless category.nil?

      job = Job.new(title, company_logo_url, company_name, description, apply_url, tags, "cryptojobslist")
      jobs << job
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
