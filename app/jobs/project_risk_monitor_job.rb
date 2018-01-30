# frozen_string_literal: true

class ProjectRiskMonitorJob < ApplicationJob
  queue_as :default

  def perform
    Project.running.each do |project|
      Rails.logger.info("Checking alerts to project: #{project.full_name}")
      company = project.customer.company

      company.project_risk_configs.each do |risk|
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
    end
  end

  private

  def process_no_money_to_deadline(risk, project)
    if project.money_per_deadline < risk.low_yellow_value
      create_alert(project, risk, project.money_per_deadline, :green)
    elsif project.money_per_deadline > risk.high_yellow_value
      create_alert(project, risk, project.money_per_deadline, :red)
    else
      create_alert(project, risk, project.money_per_deadline, :yellow)
    end
  end

  def process_backlog_growth_throughput_rate(risk, project)
    if project.backlog_growth_throughput_rate < risk.low_yellow_value
      create_alert(project, risk, project.backlog_growth_throughput_rate, :green)
    elsif project.backlog_growth_throughput_rate > risk.high_yellow_value
      create_alert(project, risk, project.backlog_growth_throughput_rate, :red)
    else
      create_alert(project, risk, project.backlog_growth_throughput_rate, :yellow)
    end
  end

  def process_not_enough_available_hours(risk, project)
    if project.required_hours_per_available_hours < risk.low_yellow_value
      create_alert(project, risk, project.required_hours_per_available_hours, :green)
    elsif project.required_hours_per_available_hours > risk.high_yellow_value
      create_alert(project, risk, project.required_hours_per_available_hours, :red)
    else
      create_alert(project, risk, project.required_hours_per_available_hours, :yellow)
    end
  end

  def process_flow_pressure(risk, project)
    if project.flow_pressure < risk.low_yellow_value
      create_alert(project, risk, project.flow_pressure, :green)
    elsif project.flow_pressure > risk.high_yellow_value
      create_alert(project, risk, project.flow_pressure, :red)
    else
      create_alert(project, risk, project.flow_pressure, :yellow)
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
