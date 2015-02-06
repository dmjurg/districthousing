require 'csv'
require 'open-uri'

# Load information from all PDFs in public/forms that don't already
# exist in the database.  PDFs that are already in the database will be
# untouched, but PDFs not in the database will be added and given a name based
# on their filename.
HousingForm.delete_all
FormField.delete_all

def download_pdf uri, name
  # Download the file to the public/forms/ directory, and generate a path
  output_filename = "public/forms/#{name}.pdf"
  system("wget #{uri} --output-document=#{output_filename}")
  return output_filename
end

def pdf_filename_base csv_row
  return "#{csv_row['lat']}_#{csv_row['lng']}"
end

HousingForm.transaction do
  FormField.transaction do
    CSV.foreach(Rails.root.join("public","buildings3.csv"), :headers => true) do |row|
      path = nil
      unless row['uri'].blank?
        path = download_pdf(row['uri'], pdf_filename_base(row))
      end
      HousingForm.create(name: row['Property Name'], location: row['Property Address'], lat: row['lat'], long: row['lng'], path: path)
    end
  end
end

# Now, make a bunch of fake applicants.

require 'faker'

Applicant.destroy_all
Person.destroy_all
User.destroy_all
Residence.destroy_all
Address.destroy_all
Income.destroy_all
IncomeType.destroy_all
Employment.destroy_all
CriminalHistory.destroy_all
CrimeType.destroy_all

# Populate income_types
IncomeType.destroy_all
IncomeType.create(name: "salary", label: "Salary / Full-Time Employment Income", active: true)
IncomeType.create(name: "military", label: "Military Income", active: true)
IncomeType.create(name: "part-time", label: "Part-Time Employment Income", active: true)
IncomeType.create(name: "self", label: "Self-Employment Income", active: true)
IncomeType.create(name: "social_security", label: "Social Security Income", active: true)
IncomeType.create(name: "disability_benefits", label: "Disability Benefits", active: true)
IncomeType.create(name: "military", label: "Military Income", active: true)
IncomeType.create(name: "veterans_benefits", label: "Veterans Benefits", active: true)
IncomeType.create(name: "commissions", label: "Commissions", active: true)
IncomeType.create(name: "child_support", label: "Child Support", active: true)
IncomeType.create(name: "rental", label: "Rental Income", active: true)
IncomeType.create(name: "stock", label: "Stock Income", active: true)
IncomeType.create(name: "insurance", label: "Insurance Income", active: true)
IncomeType.create(name: "trust_fund", label: "Trust Fund Income", active: true)
IncomeType.create(name: "government_assistance", label: "Government Assistance", active: true)
IncomeType.create(name: "cash_gifts", label: "Cash Gifts", active: true)
IncomeType.create(name: "workers_compensation", label: "Worker's Compensation", active: true)
IncomeType.create(name: "severance", label: "Severance", active: true)
IncomeType.create(name: "lottery", label: "Lottery", active: true)
IncomeType.create(name: "alimony", label: "Alimony", active: true)
IncomeType.create(name: "scholarship", label: "Scholarship", active: true)

# Populate crime types
CrimeType.create(name: "felony", label: "Felony")
CrimeType.create(name: "sex_offense", label: "Sex Offense")
CrimeType.create(name: "evicted_from_residence", label: "Evicted from your residence")
CrimeType.create(name: "evicted_from_residence_for_drugs", label: "Evicted from your residence because of drug or stubstance abuse")

# Seed a test user
test_user = User.create(
  :email => "testuser@districthousing.org",
  :password => "password"
)

30.times do
  ApplicantFactory.make_a_sample_applicant(test_user)
end

sample_user = User.create(
  :email => "sampleuser@districthousing.org",
  :password => "password"
)
sample_user.role = User::USER_ROLES[:sample]
sample_user.save!

ApplicantFactory.make_a_sample_applicant(sample_user)
