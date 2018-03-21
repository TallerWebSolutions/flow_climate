# frozen_string_literal: true

RSpec.describe ProjectRiskAlertsRepository, type: :repository do
  describe '#group_projects_risk_colors' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, start_date: 1.week.ago }
    let(:second_project) { Fabricate :project, customer: customer, start_date: 1.week.ago }
    let(:third_project) { Fabricate :project, customer: customer, end_date: 1.week.from_now }

    let(:first_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :no_money_to_deadline }
    let(:second_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :backlog_growth_rate }
    let!(:first_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: first_project, alert_color: :green, created_at: Time.zone.now }
    let!(:second_alert) { Fabricate :project_risk_alert, project_risk_config: second_risk_config, project: first_project, alert_color: :red, created_at: 1.hour.ago }

    let(:third_risk_config) { Fabricate :project_risk_config, project: second_project, risk_type: :no_money_to_deadline }
    let(:fourth_risk_config) { Fabricate :project_risk_config, project: second_project, risk_type: :backlog_growth_rate }
    let!(:third_alert) { Fabricate :project_risk_alert, project_risk_config: third_risk_config, project: second_project, alert_color: :yellow, created_at: Time.zone.now }
    let!(:fourth_alert) { Fabricate :project_risk_alert, project_risk_config: third_risk_config, project: second_project, alert_color: :red, created_at: 1.hour.ago }

    let(:five_risk_config) { Fabricate :project_risk_config, project: third_project, risk_type: :no_money_to_deadline }
    let(:six_risk_config) { Fabricate :project_risk_config, project: third_project, risk_type: :not_enough_available_hours }
    let!(:five_alert) { Fabricate :project_risk_alert, project_risk_config: five_risk_config, project: third_project, alert_color: :green, created_at: Time.zone.now }
    let!(:six_alert) { Fabricate :project_risk_alert, project_risk_config: six_risk_config, project: third_project, alert_color: :red, created_at: 1.hour.ago }
    let!(:seventh_alert) { Fabricate :project_risk_alert, project_risk_config: six_risk_config, project: third_project, alert_color: :yellow, created_at: 30.minutes.ago }

    it { expect(ProjectRiskAlertsRepository.instance.group_projects_risk_colors(Project.all, :backlog_growth_rate)).to eq('red' => 1) }
    it { expect(ProjectRiskAlertsRepository.instance.group_projects_risk_colors(Project.all, :no_money_to_deadline)).to eq('green' => 2, 'yellow' => 1) }
  end
end
