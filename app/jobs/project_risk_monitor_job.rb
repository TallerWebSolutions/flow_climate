# frozen_string_literal: true

class ProjectRiskMonitorJob < ApplicationJob
  queue_as :default

  def perform
    Project.all.each do |project|
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
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: :green, alert_value: project.money_per_deadline)
    elsif project.money_per_deadline > risk.high_yellow_value
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: :red, alert_value: project.money_per_deadline)
    else
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: :yellow, alert_value: project.money_per_deadline)
    end
  end

  def process_backlog_growth_throughput_rate(risk, project)
    if project.backlog_growth_throughput_rate < risk.low_yellow_value
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: :green, alert_value: project.backlog_growth_throughput_rate)
    elsif project.backlog_growth_throughput_rate > risk.high_yellow_value
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: :red, alert_value: project.backlog_growth_throughput_rate)
    else
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: :yellow, alert_value: project.backlog_growth_throughput_rate)
    end
  end

  def process_not_enough_available_hours(risk, project)
    if project.required_hours_per_available_hours < risk.low_yellow_value
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: :green, alert_value: project.required_hours_per_available_hours)
    elsif project.required_hours_per_available_hours > risk.high_yellow_value
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: :red, alert_value: project.required_hours_per_available_hours)
    else
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: :yellow, alert_value: project.required_hours_per_available_hours)
    end
  end

  def process_flow_pressure(risk, project)
    if project.flow_pressure < risk.low_yellow_value
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: :green, alert_value: project.flow_pressure)
    elsif project.flow_pressure > risk.high_yellow_value
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: :red, alert_value: project.flow_pressure)
    else
      ProjectRiskAlert.create(project: project, project_risk_config: risk, alert_color: :yellow, alert_value: project.flow_pressure)
    end
  end
end
