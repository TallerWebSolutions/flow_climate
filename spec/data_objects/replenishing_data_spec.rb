# frozen_string_literal: true

RSpec.describe ReplenishingData, type: :data_objects do
  before { travel_to Time.zone.local(2019, 2, 1, 10, 0, 0) }

  after { travel_back }

  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }

  let(:team) { Fabricate :team, company: company }

  let!(:first_project) { Fabricate :project, customer: customer, team: team, name: 'first_project', status: :executing, start_date: 4.months.ago, end_date: Time.zone.today }
  let!(:second_project) { Fabricate :project, customer: customer, team: team, name: 'second_project', status: :executing, start_date: 2.months.ago, end_date: 3.days.from_now }
  let!(:third_project) { Fabricate :project, customer: customer, team: team, name: 'third_project', status: :executing, start_date: 1.month.ago, end_date: 1.week.from_now }

  let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: 3.months.ago, end_date: 1.week.ago }
  let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: 2.months.ago, end_date: 4.days.ago }
  let!(:third_demand) { Fabricate :demand, project: second_project, commitment_date: 2.days.ago, end_date: 1.day.ago }
  let!(:fourth_demand) { Fabricate :demand, project: third_project, commitment_date: 1.day.ago, end_date: Time.zone.today }

  let!(:first_project_closed_demands) { Fabricate.times(6, :demand, project: first_project, commitment_date: nil, end_date: 1.week.ago) }
  let!(:second_project_closed_demands) { Fabricate.times(2, :demand, project: second_project, commitment_date: 1.week.ago, end_date: 1.week.ago) }

  let!(:first_project_opened_demands) { Fabricate.times(7, :demand, project: first_project, commitment_date: nil, end_date: nil) }
  let!(:second_project_opened_demands) { Fabricate.times(3, :demand, project: second_project, commitment_date: Time.zone.yesterday, end_date: nil) }

  describe '#summary_infos' do
    context 'having data' do
      subject(:replenishing_data) { ReplenishingData.new(team) }

      let!(:company_config) { Fabricate :company_settings, company: company, max_active_parallel_projects: 2, max_flow_pressure: 3 }
      let!(:projects) { Fabricate.times(2, :project, customer: customer, start_date: Time.zone.today, end_date: Time.zone.today) }
      let!(:other_projects) { Fabricate.times(2, :project, customer: customer, start_date: 1.month.from_now, end_date: 1.month.from_now) }

      it 'returns the hash value' do
        expect(replenishing_data.summary_infos[:four_last_throughputs]).to eq [0, 0, 0, 9]
        expect(replenishing_data.summary_infos[:average_throughput]).to eq 2

        project_data_to_replenish = replenishing_data.project_data_to_replenish
        expect(project_data_to_replenish[0][:name]).to eq first_project.full_name

        expect(project_data_to_replenish[0][:id]).to eq first_project.id
        expect(project_data_to_replenish[0][:name]).to eq first_project.full_name
        expect(project_data_to_replenish[0][:end_date]).to eq first_project.end_date
        expect(project_data_to_replenish[0][:weeks_to_end_date]).to eq first_project.remaining_weeks
        expect(project_data_to_replenish[0][:remaining_backlog]).to eq first_project.remaining_backlog
        expect(project_data_to_replenish[0][:relative_flow_pressure]).to be_within(0.1).of(68.60)
        expect(project_data_to_replenish[0][:qty_using_pressure]).to be_within(0.9).of(1.37)
        expect(project_data_to_replenish[0][:leadtime_80]).to be_within(0.1).of(79.56666)
        expect(project_data_to_replenish[0][:qty_selected_last_week]).to eq 0
        expect(project_data_to_replenish[0][:work_in_progress]).to eq 0
        expect(project_data_to_replenish[0][:montecarlo_80_percent]).to be_within(30).of(125)
        expect(project_data_to_replenish[0][:throughput_last_week]).to eq 7
        expect(project_data_to_replenish[0][:customer_happiness]).to be_within(0.005).of(0.007)

        expect(project_data_to_replenish[1][:id]).to eq second_project.id
        expect(project_data_to_replenish[1][:name]).to eq second_project.full_name
        expect(project_data_to_replenish[1][:end_date]).to eq second_project.end_date
        expect(project_data_to_replenish[1][:weeks_to_end_date]).to eq second_project.remaining_weeks
        expect(project_data_to_replenish[1][:remaining_backlog]).to eq second_project.remaining_backlog
        expect(project_data_to_replenish[1][:relative_flow_pressure]).to be_within(0.9).of(21.13)
        expect(project_data_to_replenish[1][:qty_using_pressure]).to be_within(0.1).of(0.33587)
        expect(project_data_to_replenish[1][:leadtime_80]).to be_within(0.1).of(0.60000)
        expect(project_data_to_replenish[1][:qty_selected_last_week]).to eq 2
        expect(project_data_to_replenish[1][:work_in_progress]).to eq 3
        expect(project_data_to_replenish[1][:montecarlo_80_percent]).to be_within(40).of(184)
        expect(project_data_to_replenish[1][:throughput_last_week]).to eq 2
        expect(project_data_to_replenish[1][:customer_happiness]).to be_within(0.005).of(0.005)

        expect(project_data_to_replenish[2][:id]).to eq third_project.id
        expect(project_data_to_replenish[2][:name]).to eq third_project.full_name
        expect(project_data_to_replenish[2][:end_date]).to eq third_project.end_date
        expect(project_data_to_replenish[2][:weeks_to_end_date]).to eq third_project.remaining_weeks
        expect(project_data_to_replenish[2][:remaining_backlog]).to eq third_project.remaining_backlog
        expect(project_data_to_replenish[2][:relative_flow_pressure]).to be_within(0.9).of(10.26)
        expect(project_data_to_replenish[2][:qty_using_pressure]).to be_within(0.1).of(0.15776)
        expect(project_data_to_replenish[2][:leadtime_80]).to be_within(0.2).of(0.50)
        expect(project_data_to_replenish[2][:qty_selected_last_week]).to eq 0
        expect(project_data_to_replenish[2][:work_in_progress]).to eq 0
        expect(project_data_to_replenish[2][:montecarlo_80_percent]).to eq 0
        expect(project_data_to_replenish[2][:throughput_last_week]).to eq 0
      end
    end

    context 'having no data' do
      subject(:replenishing_data) { ReplenishingData.new(other_team) }

      let(:other_team) { Fabricate :team, company: company }

      it 'returns nil' do
        expect(replenishing_data.summary_infos[:four_last_throughputs]).to be_nil
      end
    end
  end
end
