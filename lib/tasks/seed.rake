# frozen_string_literal: true

namespace :seed do
  desc 'add Taller legacy data'
  task taller_data: :environment do
    company = Company.where(name: 'Taller').first
    TeamMember.destroy_all
    TeamMember.create!(company: company, name: 'Becker', monthly_payment: 3600, hours_per_month: 160, billable_type: TeamMember.billable_types[:outsourcing])
    TeamMember.create!(company: company, name: 'Joseph', monthly_payment: 1900, hours_per_month: 120, billable_type: TeamMember.billable_types[:outsourcing])
    TeamMember.create!(company: company, name: 'Lucas', monthly_payment: 4500, hours_per_month: 160, billable_type: TeamMember.billable_types[:outsourcing])
    TeamMember.create!(company: company, name: 'Marcos', monthly_payment: 1800, hours_per_month: 160, billable_type: TeamMember.billable_types[:outsourcing])
    TeamMember.create!(company: company, name: 'Recidive', monthly_payment: 5500, hours_per_month: 160, billable_type: TeamMember.billable_types[:outsourcing])
    TeamMember.create!(company: company, name: 'Renato', monthly_payment: 5000, hours_per_month: 120, billable_type: TeamMember.billable_types[:outsourcing])
    TeamMember.create!(company: company, name: 'Sebas', monthly_payment: 6000, hours_per_month: 160, billable_type: TeamMember.billable_types[:outsourcing])
    TeamMember.create!(company: company, name: 'William', monthly_payment: 4000, hours_per_month: 160, billable_type: TeamMember.billable_types[:outsourcing])
    TeamMember.create!(company: company, name: 'Italo', monthly_payment: 2800, hours_per_month: 120, billable_type: TeamMember.billable_types[:outsourcing])
    TeamMember.create!(company: company, name: 'Rodrigo', monthly_payment: 3000, hours_per_month: 160, billable_type: TeamMember.billable_types[:outsourcing])
    TeamMember.create!(company: company, name: 'Wharley', monthly_payment: 5200, hours_per_month: 160, billable_type: TeamMember.billable_types[:outsourcing])
    TeamMember.create!(company: company, name: 'Celso', monthly_payment: 7500, hours_per_month: 160, billable_type: TeamMember.billable_types[:consulting])
    TeamMember.create!(company: company, name: 'Anderson', monthly_payment: 3500, hours_per_month: 160, billable: false, billable_type: nil)
    TeamMember.create!(company: company, name: 'Rafael', monthly_payment: 6000, hours_per_month: 160, billable: false, billable_type: nil)
    TeamMember.create!(company: company, name: 'Helal', monthly_payment: 8200, hours_per_month: 160, billable: false, billable_type: nil)
    TeamMember.create!(company: company, name: 'Raquel', monthly_payment: 500, hours_per_month: 60, billable: false, billable_type: nil)
    TeamMember.create!(company: company, name: 'Edmar', monthly_payment: 3000, hours_per_month: 60, billable_type: TeamMember.billable_types[:outsourcing])
  end
end
