# frozen_string_literal: true

class FlowAnalyticData
  attr_reader :company

  def initialize(company)
    @company = company
  end

  def best_month_to_start_a_project(start_date)
    max_allowed_active_projects = company.company_settings&.max_active_parallel_projects
    return I18n.t('flow_analytics.best_month_to_start.no_config') if max_allowed_active_projects.blank? || max_allowed_active_projects.zero?
    active_projects_count = ProjectsRepository.instance.active_projects_in_month(@company.projects, start_date).count
    return best_month_to_start_a_project(start_date + 1.month) if active_projects_count >= max_allowed_active_projects
    I18n.t('flow_analytics.best_month_to_start.best_month_html', best_month: format_month_to_message(start_date), project_portfolio_room: (max_allowed_active_projects - active_projects_count))
  end

  def financial_debt_to_sold_projects(start_date)
    last_company_cost = @company.financial_informations.order(:finances_date).last&.expenses_total
    return I18n.t('flow_analytics.financial_debt.no_finances') if last_company_cost.blank?
    money_to_month = ProjectsRepository.instance.money_to_month(@company.projects, start_date)
    return financial_debt_to_sold_projects(start_date + 1.month) if money_to_month >= last_company_cost
    I18n.t('flow_analytics.financial_debt.financial_debt_month_html', debt_month: format_month_to_message(start_date), debt_difference: format_number_to_message(last_company_cost, money_to_month))
  end

  private

  def format_number_to_message(last_company_cost, money_to_month)
    ActionController::Base.helpers.number_to_currency(money_to_month - last_company_cost)
  end

  def format_month_to_message(start_date)
    I18n.l(start_date, format: '%B/%Y')
  end
end
