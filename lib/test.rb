require "selenium-webdriver"

def get_jobs_from_landing
  url = "https://landing.jobs/jobs?&hd=false&t_co=false&t_st=false"
  # html = HTTParty.get(url)
  # page = Nokogiri::HTML(open(url))
  puts "url: #{url}"
  driver = Selenium::WebDriver.for :firefox
  puts "will navigate"
  driver.navigate_to url
  puts driver.page_source
  
  # puts page
end

get_jobs_from_landing