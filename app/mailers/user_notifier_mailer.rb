# frozen_string_literal: true

class UserNotifierMailer < ApplicationMailer
  def company_weekly_bulletin(users, company)
    @company = company
    assign_project_informations(company)
    emails = users.to_notify_email.pluck(:email_address)
    return nil if emails.blank?

    @demands_delivered_last_week = Demand.kept.where('EXTRACT(week FROM end_date) = :week AND EXTRACT(year FROM end_date) = :year', week: 1.week.ago.to_date.cweek, year: 1.week.ago.to_date.cwyear)
    Rails.logger.info("Notifying users #{emails}")
    mail(to: emails, subject: I18n.t('projects.portfolio_bulletin.subject'))
  end

  def notify_new_red_alert(project, risk, project_color, alert_value)
    @project = project
    @risk = risk
    @previous_color = project_color
    @alert_value = alert_value
    emails = project.company.users.to_notify_email.pluck(:email_address)
    Rails.logger.info("Notifying users on red project #{emails}")
    mail(to: emails, subject: I18n.t('projects.red_alert.subject', target_name: project.name))
  end

  def jira_requested_csv(user, content)
    @user = user
    emails = [user.email_address]
    now_to_filename = Time.zone.now
    attachments["demands-#{now_to_filename}.csv"] = { mime_type: 'text/csv', content: content }
    Rails.logger.info("Sending csv to the user #{emails}")
    mail(to: emails, subject: I18n.t('exports.jira_requested_csv.subject'))
  end

  def plan_requested(user, user_plan)
    @user = user
    @user_plan = user_plan
    emails = User.admins.map(&:email_address)
    Rails.logger.info("New plan requested email sent to #{emails}")
    mail(to: emails, subject: I18n.t('plans.request.subject'))
  end

  def async_activity_finished(user_email, user_name, activity_title, object_title, activity_started_at, activity_finished_at, object_url)
    @user_name = user_name
    @activity_title = activity_title
    @object_title = object_title
    @activity_started_at = activity_started_at
    @activity_finished_at = activity_finished_at
    @object_url = object_url

    Rails.logger.info("Activity #{@activity_title}-#{@object_title} finished email notification sent to #{@user_email}")
    mail(to: user_email, subject: I18n.t('async_activity.notification.subject', activity_title: @activity_title, object_title: @object_title))
  end

  def user_invite_to_customer(user_email, customer_name, registration_url)
    @user_name = user_email
    @customer_name = customer_name
    @registration_url = registration_url

    Rails.logger.info("Inviting user #{user_email} for customer #{customer_name}")
    mail(to: user_email, subject: I18n.t('user_notifier_mailer.user_invite_to_customer.subject', customer_name: customer_name))
  end

  def send_auth_token(company, user_email)
    @auth_token = company.api_token
    Rails.logger.info("Sending auth token to #{user_email}")
    mail(to: user_email, subject: I18n.t('company.send_auth_token.subject'))
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
