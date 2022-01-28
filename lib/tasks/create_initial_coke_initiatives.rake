# frozen-string-literal: true

namespace :initiatives do
  task create_iniciatives: :environment do
    company = Company.find(43)
    project_names = company.projects.map(&:name).map { |name| name.split('-')[0].strip }.uniq.sort

    project_names.each do |name|
      initiative = Initiative.where(name: name, company: company).first_or_initialize

      projects = company.projects.where('name ILIKE :initiative_name', initiative_name: "%#{name}%")

      initiative.start_date = projects.map(&:start_date).min
      initiative.end_date = projects.map(&:end_date).max
      initiative.projects = projects

      initiative.save!
    end
  end
end
