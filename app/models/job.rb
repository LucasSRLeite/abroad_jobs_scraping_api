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

  def to_s
    "#{self.jobTitle} - #{self.companyName}"
  end
end
