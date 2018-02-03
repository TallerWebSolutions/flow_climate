# frozen_string_literal: true

class UserNotifierMailer < ApplicationMailer
  default from: 'no-reply@taller.net.br'

  def company_weekly_bulletin(company, projects_starting, projects_finishing)
    @company = company
    @projects_starting = projects_starting
    @projects_finishing = projects_finishing
    @next_starting_project = company.next_starting_project
    @next_finishing_project = company.next_finishing_project
    @top_three_flow_pressure = company.top_three_flow_pressure
    @demands_delivered = company.demands_delivered_last_week
    emails = @company.users.to_notify_email.pluck(:email)
    Rails.logger.info("Notifying users #{emails}")
    mail(to: emails, subject: t('projects.portfolio_bulletin.subject'))
  end
end
