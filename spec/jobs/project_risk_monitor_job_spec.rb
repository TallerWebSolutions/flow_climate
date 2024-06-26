# frozen_string_literal: true

RSpec.describe ProjectRiskMonitorJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued.on_queue('default')
    end
  end

  context 'having projects to process alerts' do
    let(:first_user) { Fabricate :user }
    let!(:company) { Fabricate :company, users: [first_user] }
    let(:customer) { Fabricate :customer, company: company }

    context 'having alerts configured' do
      context 'no duplication' do
        let!(:first_project) { Fabricate :project, company: company, customers: [customer], status: :executing, start_date: Time.zone.today }
        let!(:second_project) { Fabricate :project, company: company, customers: [customer], status: :finished, start_date: Time.zone.today }
        let!(:third_project) { Fabricate :project, company: company, customers: [customer], status: :cancelled, start_date: Time.zone.today }

        let!(:first_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 30 }
        let!(:second_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 30, active: false }
        let!(:third_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :backlog_growth_rate, low_yellow_value: 10, high_yellow_value: 30 }
        let!(:fourth_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :not_enough_available_hours, low_yellow_value: 10, high_yellow_value: 30 }
        let!(:fifth_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :flow_pressure, low_yellow_value: 10, high_yellow_value: 30 }

        context 'when the project is in the green area' do
          it 'creates a green alert to the active projects' do
            allow_any_instance_of(Project).to receive(:money_per_deadline).and_return(2)
            allow_any_instance_of(Project).to receive(:backlog_growth_throughput_rate).and_return(3)
            allow_any_instance_of(Project).to receive(:required_hours_per_available_hours).and_return(4)
            allow_any_instance_of(Project).to receive(:flow_pressure).and_return(1)

            described_class.perform_now
            expect(first_project.reload.project_risk_alerts.count).to eq 4
            expect(second_project.reload.project_risk_alerts.count).to eq 0
            expect(third_project.reload.project_risk_alerts.count).to eq 0

            expect(first_project.reload.project_risk_alerts.pluck(:alert_color)).to eq %w[green green green green]
            expect(first_project.reload.project_risk_alerts.pluck(:project_risk_config_id)).to match_array [first_risk_config.id, third_risk_config.id, fourth_risk_config.id, fifth_risk_config.id]
            expect(first_project.reload.project_risk_alerts.pluck(:alert_value)).to match_array [first_project.money_per_deadline, first_project.backlog_growth_throughput_rate, first_project.required_hours_per_available_hours, first_project.flow_pressure]
          end
        end

        context 'when the project is in the yellow area' do
          it 'creates a green alert to the project' do
            allow_any_instance_of(Project).to receive(:money_per_deadline).and_return(20)
            allow_any_instance_of(Project).to receive(:backlog_growth_throughput_rate).and_return(25)
            allow_any_instance_of(Project).to receive(:required_hours_per_available_hours).and_return(27)
            allow_any_instance_of(Project).to receive(:flow_pressure).and_return(29)

            described_class.perform_now
            expect(first_project.reload.project_risk_alerts.count).to eq 4
            expect(first_project.reload.project_risk_alerts.pluck(:alert_color)).to eq %w[yellow yellow yellow yellow]
            expect(first_project.reload.project_risk_alerts.pluck(:project_risk_config_id)).to match_array [first_risk_config.id, third_risk_config.id, fourth_risk_config.id, fifth_risk_config.id]
            expect(first_project.reload.project_risk_alerts.pluck(:alert_value)).to match_array [first_project.money_per_deadline, first_project.backlog_growth_throughput_rate, first_project.required_hours_per_available_hours, first_project.flow_pressure]
          end
        end

        context 'when the project is in the red area' do
          it 'creates a green alert to the project' do
            ProjectRiskAlert.create(created_at: Time.zone.today, project: first_project, project_risk_config: first_risk_config, alert_color: :red, alert_value: 30)

            allow_any_instance_of(Project).to receive(:money_per_deadline).and_return(40)
            allow_any_instance_of(Project).to receive(:backlog_growth_throughput_rate).and_return(45)
            allow_any_instance_of(Project).to receive(:required_hours_per_available_hours).and_return(55)
            allow_any_instance_of(Project).to receive(:flow_pressure).and_return(65)

            expect(UserNotifierMailer).to receive(:notify_new_red_alert).exactly(3).times.and_call_original

            described_class.perform_now
            expect(first_project.reload.project_risk_alerts.count).to eq 4
            expect(first_project.reload.project_risk_alerts.pluck(:alert_color)).to eq %w[red red red red]
            expect(first_project.reload.project_risk_alerts.pluck(:project_risk_config_id)).to match_array [first_risk_config.id, third_risk_config.id, fourth_risk_config.id, fifth_risk_config.id]
            expect(first_project.reload.project_risk_alerts.pluck(:alert_value)).to match_array [first_project.money_per_deadline, first_project.backlog_growth_throughput_rate, first_project.required_hours_per_available_hours, first_project.flow_pressure]
          end
        end
      end

      context 'having duplication' do
        context 'when already has the same alert for the date' do
          let!(:first_project) { Fabricate :project, company: company, customers: [customer], status: :executing, start_date: Time.zone.today }
          let!(:first_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 30 }

          it 'does not create the new alert and will update the existent one' do
            ProjectRiskAlert.create(created_at: Time.zone.today, project: first_project, project_risk_config: first_risk_config, alert_color: :green, alert_value: 30)
            allow_any_instance_of(Project).to receive(:money_per_deadline).and_return(40)

            described_class.perform_now
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
