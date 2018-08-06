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