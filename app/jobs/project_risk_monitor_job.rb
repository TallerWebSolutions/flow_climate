# frozen_string_literal: true

class ProjectRiskMonitorJob < ApplicationJob
  queue_as :default

  def perform
    Project.running.each do |project|
      Rails.logger.info("Checking alerts to project: #{project.full_name}")
      company = project.customer.company

      company.project_risk_configs.each do |risk|
        process_risk(project, risk)
      end
    end
  end

  private

  def process_risk(project, risk)
    if risk.no_money_to_deadline?
      process_no_money_to_deadline(risk, project)
    elsif risk.backlog_growth_rate?
      process_backlog_growth_throughput_rate(risk, project)
    elsif risk.not_enough_available_hours?
      process_not_enough_available_hours(risk, project)
    elsif risk.flow_pressure?
      process_flow_pressure(risk, project)
    end
  end

  def process_no_money_to_deadline(risk, project)
    process_alert(risk, project, project.money_per_deadline)
  end

  def process_backlog_growth_throughput_rate(risk, project)
    process_alert(risk, project, project.backlog_growth_throughput_rate)
  end

  def process_not_enough_available_hours(risk, project)
    process_alert(risk, project, project.required_hours_per_available_hours)
  end

  def process_flow_pressure(risk, project)
    process_alert(risk, project, project.flow_pressure)
  end

  def process_alert(risk, project, result_value)
    if result_value < risk.low_yellow_value
      create_alert(project, risk, result_value, :green)
    elsif result_value > risk.high_yellow_value
      create_alert(project, risk, result_value, :red)
    else
      create_alert(project, risk, result_value, :yellow)
    end
  end

  def create_alert(project, risk, alert_value, color)
    alert = ProjectRiskAlert.where('DATE(created_at) = :created_date AND project_id = :project_id AND project_risk_config_id = :risk_id', created_date: Time.zone.today, project_id: project.id, risk_id: risk.id)
    if alert.present?
      alert.update(alert_color: color, alert_value: alert_value)
    else
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: color, alert_value: alert_value)
    end
  end
end
