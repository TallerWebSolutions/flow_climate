# frozen_string_literal: true

RSpec.describe ProjectRiskData, type: :data_object do
  context 'having projects' do
    let(:first_project) { Fabricate :project, status: :executing, start_date: 2.weeks.ago, end_date: 1.week.from_now }
    let(:second_project) { Fabricate :project, status: :waiting, start_date: 1.week.from_now, end_date: 2.weeks.from_now }
    let(:third_project) { Fabricate :project, status: :maintenance, start_date: 2.weeks.from_now, end_date: 3.weeks.from_now }

    let(:first_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :no_money_to_deadline }
    let(:second_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :backlog_growth_rate }
    let!(:first_alert) { Fabricate :project_risk_alert, project_risk_config: first_risk_config, project: first_project, alert_color: :green, created_at: Time.zone.now }
    let!(:second_alert) { Fabricate :project_risk_alert, project_risk_config: second_risk_config, project: first_project, alert_color: :red, created_at: 1.hour.ago }

    let(:third_risk_config) { Fabricate :project_risk_config, project: second_project, risk_type: :flow_pressure }
    let(:fourth_risk_config) { Fabricate :project_risk_config, project: second_project, risk_type: :backlog_growth_rate }
    let!(:third_alert) { Fabricate :project_risk_alert, project_risk_config: third_risk_config, project: second_project, alert_color: :yellow, created_at: Time.zone.now }
    let!(:fourth_alert) { Fabricate :project_risk_alert, project_risk_config: third_risk_config, project: second_project, alert_color: :red, created_at: 1.hour.ago }

    let(:five_risk_config) { Fabricate :project_risk_config, project: third_project, risk_type: :profit_margin }
    let(:six_risk_config) { Fabricate :project_risk_config, project: third_project, risk_type: :not_enough_available_hours }
    let!(:five_alert) { Fabricate :project_risk_alert, project_risk_config: five_risk_config, project: third_project, alert_color: :green, created_at: Time.zone.now }
    let!(:six_alert) { Fabricate :project_risk_alert, project_risk_config: six_risk_config, project: third_project, alert_color: :red, created_at: 1.hour.ago }
    let!(:seventh_alert) { Fabricate :project_risk_alert, project_risk_config: six_risk_config, project: third_project, alert_color: :yellow, created_at: 30.minutes.ago }

    describe '.initialize' do
      subject(:risk_data) { ProjectRiskData.new(Project.all) }

      it 'retrieves the last risk alert informations and mounts the data to the charts' do
        expect(risk_data.backlog_risk_alert_data).to eq [{ name: 'Vermelho', y: 1, color: '#FB283D' }]
        expect(risk_data.flowpressure_risk_alert_data).to eq [{ name: 'Amarelo', y: 1, color: '#F9FB28' }]
        expect(risk_data.money_risk_alert_data).to eq [{ name: 'Verde', y: 1, color: '#179A02' }]
        expect(risk_data.hours_risk_alert_data).to eq [{ name: 'Amarelo', y: 1, color: '#F9FB28' }]
        expect(risk_data.profit_risk_alert_data).to eq [{ name: 'Verde', y: 1, color: '#179A02' }]
      end
    end
  end
end
