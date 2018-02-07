# frozen_string_literal: true

class ProjectsRepository
  include Singleton

  def running_projects_in_month(company, required_date)
    Project.joins(:customer).active.where('customers.company_id = :company_id AND ((start_date <= :end_date AND end_date >= :start_date) OR (start_date >= :start_date AND end_date <= :end_date) OR (start_date <= :end_date AND start_date >= :start_date))', company_id: company.id, start_date: required_date.beginning_of_month, end_date: required_date.end_of_month)
  end
end
