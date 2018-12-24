# frozen_string_literal: true

class UserNotifierMailer < ApplicationMailer
  default from: 'no-reply@taller.net.br'

  def company_weekly_bulletin(users, company)
    @company = company
    assign_project_informations(company)
    emails = users.to_notify_email.pluck(:email)
    @demands_delivered_last_week = Demand.kept.where('EXTRACT(week FROM end_date) = :week AND EXTRACT(year FROM end_date) = :year', week: 1.week.ago.to_date.cweek, year: 1.week.ago.to_date.cwyear)
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

  def jira_requested_csv(user, content)
    @user = user
    emails = [user.email]
    now_to_filename = Time.zone.now
    attachments["demands-#{now_to_filename}.csv"] = { mime_type: 'text/csv', content: content }
    Rails.logger.info("Sending csv to the user #{emails}")
    mail(to: emails, subject: I18n.t('exports.jira_requested_csv.subject'))
  end

  def plan_requested(user, user_plan)
    @user = user
    @user_plan = user_plan
    emails = User.admins.map(&:email)
    Rails.logger.info("New plan requested email sent to #{emails}")
    mail(to: emails, subject: I18n.t('plans.request.subject'))
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
