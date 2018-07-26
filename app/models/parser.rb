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
          logo_url = data[0].css("a").children.first.attributes["data-src"].text
        rescue
          logo_url = Parser.unwrap(data[0].css("a").text)
        end

        apply_url = Parser.unwrap("#{url}#{array_data.first.attributes["data-url"].text}")
        job_title = Parser.unwrap(data[1].css("a h2").text)
        company = Parser.unwrap(data[1].css("a h3").text)
        tags = Parser.unwrap(data[3].text.split("3>"))
        description = Parser.unwrap(array_data.last.text)

        parsed_job = Job.new(job_title, logo_url, company, description, apply_url, tags)
        parsed_jobs << parsed_job
      rescue
        next
      end
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
