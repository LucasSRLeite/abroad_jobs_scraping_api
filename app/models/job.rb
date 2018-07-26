class Job
  attr_accessor :jobTitle, :companyLogoURL, :companyName, :jobDescription, :applyURL, :tags

  def initialize(jobTitle, companyLogoURL, companyName, jobDescription, applyURL, tags)
    self.jobTitle = jobTitle
    self.companyLogoURL = companyLogoURL
    self.companyName = companyName.split(".").first
    self.jobDescription = jobDescription.force_encoding("ISO-8859-1").encode("UTF-8")
    self.applyURL = applyURL
    self.tags = tags
  end

  def to_s
    "#{self.jobTitle} - #{self.companyName}"
  end
end
