# frozen_string_literal: true

RSpec.describe ProjectRiskMonitorJob, type: :job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      ProjectRiskMonitorJob.perform_later
      expect(ProjectRiskMonitorJob).to have_been_enqueued.on_queue('default')
    end
  end

  context 'having projects to process alerts' do
    let(:first_user) { Fabricate :user }
    let!(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    context 'having alerts configured' do
      context 'no duplication' do
        let!(:first_risk_config) { Fabricate :project_risk_config, company: company, risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 30 }
        let!(:second_risk_config) { Fabricate :project_risk_config, company: company, risk_type: :backlog_growth_rate, low_yellow_value: 10, high_yellow_value: 30 }
        let!(:third_risk_config) { Fabricate :project_risk_config, company: company, risk_type: :not_enough_available_hours, low_yellow_value: 10, high_yellow_value: 30 }
        let!(:fourth_risk_config) { Fabricate :project_risk_config, company: company, risk_type: :flow_pressure, low_yellow_value: 10, high_yellow_value: 30 }

        let!(:first_project) { Fabricate :project, customer: customer, status: :executing, start_date: Time.zone.today }
        let!(:second_project) { Fabricate :project, customer: customer, status: :finished, start_date: Time.zone.today }
        let!(:third_project) { Fabricate :project, customer: customer, status: :cancelled, start_date: Time.zone.today }

        context 'when the project is in the green area' do
          it 'creates a green alert to the active projects' do
            allow_any_instance_of(Project).to receive(:money_per_deadline) { 2 }
            allow_any_instance_of(Project).to receive(:backlog_growth_throughput_rate) { 3 }
            allow_any_instance_of(Project).to receive(:required_hours_per_available_hours) { 4 }
            allow_any_instance_of(Project).to receive(:flow_pressure) { 1 }

            ProjectRiskMonitorJob.perform_now
            expect(first_project.reload.project_risk_alerts.count).to eq 4
            expect(second_project.reload.project_risk_alerts.count).to eq 0
            expect(third_project.reload.project_risk_alerts.count).to eq 0

            expect(first_project.reload.project_risk_alerts.pluck(:alert_color)).to eq %w[green green green green]
            expect(first_project.reload.project_risk_alerts.pluck(:project_risk_config_id)).to match_array [first_risk_config.id, second_risk_config.id, third_risk_config.id, fourth_risk_config.id]
            expect(first_project.reload.project_risk_alerts.pluck(:alert_value)).to match_array [first_project.money_per_deadline, first_project.backlog_growth_throughput_rate, first_project.required_hours_per_available_hours, first_project.flow_pressure]
          end
        end
        context 'when the project is in the yellow area' do
          it 'creates a green alert to the project' do
            allow_any_instance_of(Project).to receive(:money_per_deadline) { 20 }
            allow_any_instance_of(Project).to receive(:backlog_growth_throughput_rate) { 25 }
            allow_any_instance_of(Project).to receive(:required_hours_per_available_hours) { 27 }
            allow_any_instance_of(Project).to receive(:flow_pressure) { 29 }

            ProjectRiskMonitorJob.perform_now
            expect(first_project.reload.project_risk_alerts.count).to eq 4
            expect(first_project.reload.project_risk_alerts.pluck(:alert_color)).to eq %w[yellow yellow yellow yellow]
            expect(first_project.reload.project_risk_alerts.pluck(:project_risk_config_id)).to match_array [first_risk_config.id, second_risk_config.id, third_risk_config.id, fourth_risk_config.id]
            expect(first_project.reload.project_risk_alerts.pluck(:alert_value)).to match_array [first_project.money_per_deadline, first_project.backlog_growth_throughput_rate, first_project.required_hours_per_available_hours, first_project.flow_pressure]
          end
        end
        context 'when the project is in the red area' do
          it 'creates a green alert to the project' do
            allow_any_instance_of(Project).to receive(:money_per_deadline) { 40 }
            allow_any_instance_of(Project).to receive(:backlog_growth_throughput_rate) { 45 }
            allow_any_instance_of(Project).to receive(:required_hours_per_available_hours) { 55 }
            allow_any_instance_of(Project).to receive(:flow_pressure) { 65 }

            ProjectRiskMonitorJob.perform_now
            expect(first_project.reload.project_risk_alerts.count).to eq 4
            expect(first_project.reload.project_risk_alerts.pluck(:alert_color)).to eq %w[red red red red]
            expect(first_project.reload.project_risk_alerts.pluck(:project_risk_config_id)).to match_array [first_risk_config.id, second_risk_config.id, third_risk_config.id, fourth_risk_config.id]
            expect(first_project.reload.project_risk_alerts.pluck(:alert_value)).to match_array [first_project.money_per_deadline, first_project.backlog_growth_throughput_rate, first_project.required_hours_per_available_hours, first_project.flow_pressure]
          end
        end
      end

      context 'having duplication' do
        context 'when already has the same alert for the date' do
          let!(:first_risk_config) { Fabricate :project_risk_config, company: company, risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 30 }
          let!(:first_project) { Fabricate :project, customer: customer, status: :executing, start_date: Time.zone.today }

          it 'will not create the new alert and will update the existent one' do
            ProjectRiskAlert.create(created_at: Time.zone.today, project: first_project, project_risk_config: first_risk_config, alert_color: :green, alert_value: 30)
            allow_any_instance_of(Project).to receive(:money_per_deadline) { 40 }

            ProjectRiskMonitorJob.perform_now
            expect(first_project.reload.project_risk_alerts.count).to eq 1
            expect(first_project.reload.project_risk_alerts.pluck(:alert_color)).to eq %w[red]
            expect(first_project.reload.project_risk_alerts.pluck(:project_risk_config_id)).to match_array [first_risk_config.id]
            expect(first_project.reload.project_risk_alerts.pluck(:alert_value)).to match_array [first_project.money_per_deadline]
          end
        end
      end
    end
  end
end
