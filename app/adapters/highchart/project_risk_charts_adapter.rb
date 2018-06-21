# frozen_string_literal: true

module Highchart
  class ProjectRiskChartsAdapter
    attr_reader :backlog_risk_alert_data, :flowpressure_risk_alert_data, :money_risk_alert_data, :hours_risk_alert_data, :profit_risk_alert_data

    def initialize(projects)
      @backlog_risk_alert_data = mount_data_to_chart(ProjectRiskAlertsRepository.instance.group_projects_risk_colors(projects, :backlog_growth_rate))
      @flowpressure_risk_alert_data = mount_data_to_chart(ProjectRiskAlertsRepository.instance.group_projects_risk_colors(projects, :flow_pressure))
      @money_risk_alert_data = mount_data_to_chart(ProjectRiskAlertsRepository.instance.group_projects_risk_colors(projects, :no_money_to_deadline))
      @hours_risk_alert_data = mount_data_to_chart(ProjectRiskAlertsRepository.instance.group_projects_risk_colors(projects, :not_enough_available_hours))
      @profit_risk_alert_data = mount_data_to_chart(ProjectRiskAlertsRepository.instance.group_projects_risk_colors(projects, :profit_margin))
    end

    def mount_data_to_chart(grouped_risk_alerts)
      data_to_chart = []
      grouped_risk_alerts.each do |risk_color, count|
        data_to_chart.push(name: I18n.t("activerecord.attributes.project_risk_alert.enums.alert_color.#{risk_color}"), y: count, color: define_color_hex(risk_color))
      end
      data_to_chart
    end

    private

    def define_color_hex(alert_color)
      return '#F9FB28' if alert_color == 'yellow'
      return '#FB283D' if alert_color == 'red'
      '#179A02'
    end
  end
end
