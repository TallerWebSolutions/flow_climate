# frozen_string_literal: true

class UserNotifierMailer < ApplicationMailer
  default from: 'no-reply@taller.net.br'

  def company_weekly_bulletin(users, company)
    @company = company
    assign_project_informations(company)
    emails = users.to_notify_email.pluck(:email)
    Rails.logger.info("Notifying users #{emails}")
    mail(to: emails, subject: t('projects.portfolio_bulletin.subject'))
  end

  def notify_new_red_alert(project, risk, previous_color, alert_value)
    @project = project
    @risk = risk
    @previous_color = previous_color
    @alert_value = alert_value
    emails = project.customer.company.users.to_notify_email.pluck(:email)
    Rails.logger.info("Notifying users on red project #{emails}")
    mail(to: emails, subject: t('projects.red_alert.subject', project_name: project.full_name))
  end

  private

  def assign_project_informations(company)
    @projects_starting = company.projects.waiting_projects_starting_within_week
    @projects_finishing = company.projects.running_projects_finishing_within_week
    @next_starting_project = company.next_starting_project
    @next_finishing_project = company.next_finishing_project
    @top_three_flow_pressure = company.top_three_flow_pressure
    @top_three_throughput = company.top_three_throughput
    @demands_delivered = company.demands_delivered_last_week
    @red_projects = company.projects.running.select(&:red?)
  end
end
