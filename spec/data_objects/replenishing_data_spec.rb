# frozen_string_literal: true

RSpec.describe ReplenishingData, type: :data_objects do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, company: company, customer: customer }

  let(:team) { Fabricate :team, company: company, max_work_in_progress: 12 }

  describe '#summary_infos' do
    context 'with data' do
      subject(:replenishing_data) { described_class.new(team) }

      it 'returns the hash value' do
        travel_to Time.zone.local(2019, 2, 1, 10, 0, 0) do
          first_project = Fabricate :project, company: company, products: [product], customers: [customer], team: team, name: 'first_project', status: :executing, start_date: 4.months.ago, end_date: 2.weeks.from_now, max_work_in_progress: 3
          second_project = Fabricate :project, company: company, products: [product], customers: [customer], team: team, name: 'second_project', status: :executing, start_date: 2.months.ago, end_date: 3.weeks.from_now, max_work_in_progress: 2
          third_project = Fabricate :project, company: company, products: [product], customers: [customer], team: team, name: 'third_project', status: :executing, start_date: 1.month.ago, end_date: 4.weeks.from_now, max_work_in_progress: 5

          fourth_project = Fabricate :project, company: company, products: [product], customers: [customer], team: team, name: 'fourth_project', status: :executing, start_date: 1.month.from_now, end_date: 4.months.from_now, max_work_in_progress: 5
          fifth_project = Fabricate :project, company: company, products: [product], customers: [customer], team: team, name: 'fifth_project', status: :finished, start_date: 1.month.ago, end_date: 1.week.ago

          Fabricate :demand, product: product, team: team, project: first_project, created_date: 91.days.ago, commitment_date: 3.months.ago, end_date: 1.week.ago
          Fabricate :demand, product: product, team: team, project: first_project, created_date: 62.days.ago, commitment_date: 2.months.ago, end_date: 4.weeks.ago
          Fabricate :demand, product: product, team: team, project: second_project, created_date: 6.days.ago, commitment_date: 2.days.ago, end_date: 1.day.ago
          Fabricate :demand, product: product, team: team, project: third_project, created_date: 3.days.ago, commitment_date: 1.day.ago, end_date: Time.zone.today
          Fabricate :demand, product: product, team: team, project: third_project, created_date: 2.weeks.ago, commitment_date: nil, end_date: 1.week.ago
          Fabricate.times(6, :demand, product: product, team: team, project: first_project, commitment_date: 1.week.ago, end_date: 1.week.ago)
          Fabricate.times(2, :demand, product: product, team: team, project: second_project, commitment_date: 1.week.ago, end_date: 1.week.ago)
          Fabricate :company_settings, company: company, max_active_parallel_projects: 2, max_flow_pressure: 3
          Fabricate.times(2, :project, company: company, customers: [customer], start_date: 2.weeks.ago, end_date: Time.zone.today)
          Fabricate.times(2, :project, company: company, customers: [customer], start_date: 1.month.from_now, end_date: 1.month.from_now)

          expect(replenishing_data.team_projects).to match_array [first_project, second_project, third_project, fourth_project, fifth_project]
          expect(replenishing_data.summary_infos[:four_last_throughputs]).to eq [1, 0, 0, 10]
          expect(replenishing_data.summary_infos[:average_throughput]).to eq 2
          expect(replenishing_data.summary_infos[:team_wip]).to eq 12

          project_data_to_replenish = replenishing_data.project_data_to_replenish
          expect(project_data_to_replenish[0][:name]).to eq first_project.name
          expect(project_data_to_replenish.count).to eq 3

          expect(project_data_to_replenish[0][:id]).to eq first_project.id
          expect(project_data_to_replenish[0][:name]).to eq first_project.name
          expect(project_data_to_replenish[0][:start_date]).to eq first_project.start_date
          expect(project_data_to_replenish[0][:aging_today]).to eq 123
          expect(project_data_to_replenish[0][:end_date]).to eq first_project.end_date
          expect(project_data_to_replenish[0][:weeks_to_end_date]).to eq first_project.remaining_weeks
          expect(project_data_to_replenish[0][:remaining_backlog]).to eq first_project.remaining_backlog
          expect(project_data_to_replenish[0][:relative_flow_pressure]).to be_within(0.1).of(40)
          expect(project_data_to_replenish[0][:qty_using_pressure]).to be_within(0.9).of(1.37)
          expect(project_data_to_replenish[0][:leadtime_80]).to be_within(0.1).of(1_762_560.0)
          expect(project_data_to_replenish[0][:qty_selected_last_week]).to eq 6
          expect(project_data_to_replenish[0][:work_in_progress]).to eq 0
          expect(project_data_to_replenish[0][:montecarlo_80_percent]).to be_within(12).of(40)
          expect(project_data_to_replenish[0][:team_based_montecarlo_80_percent]).to be_within(10).of(41)
          expect(project_data_to_replenish[0][:throughput_last_week]).to eq 7
          expect(project_data_to_replenish[0][:customer_happiness]).to be_within(0.05).of(0.04)
          expect(project_data_to_replenish[0][:max_work_in_progress]).to eq 3
          expect(project_data_to_replenish[0][:throughput_data_size]).to eq 17
          expect(project_data_to_replenish[0][:customers_names]).to match_array first_project.customers.map(&:name)
          expect(project_data_to_replenish[0][:products_names]).to match_array first_project.products.map(&:name)

          expect(project_data_to_replenish[1][:id]).to eq second_project.id
          expect(project_data_to_replenish[1][:name]).to eq second_project.name
          expect(project_data_to_replenish[1][:start_date]).to eq second_project.start_date
          expect(project_data_to_replenish[1][:aging_today]).to eq 62
          expect(project_data_to_replenish[1][:end_date]).to eq second_project.end_date
          expect(project_data_to_replenish[1][:weeks_to_end_date]).to eq second_project.remaining_weeks
          expect(project_data_to_replenish[1][:remaining_backlog]).to eq second_project.remaining_backlog
          expect(project_data_to_replenish[1][:relative_flow_pressure]).to be_within(0.9).of(33.61)
          expect(project_data_to_replenish[1][:qty_using_pressure]).to be_within(0.1).of(0.6)
          expect(project_data_to_replenish[1][:leadtime_80]).to be_within(0.1).of(51_840.0)
          expect(project_data_to_replenish[1][:qty_selected_last_week]).to eq 2
          expect(project_data_to_replenish[1][:work_in_progress]).to eq 0
          expect(project_data_to_replenish[1][:montecarlo_80_percent]).to be_within(50).of(184)
          expect(project_data_to_replenish[1][:throughput_last_week]).to eq 2
          expect(project_data_to_replenish[1][:customer_happiness]).to be_within(0.05).of(0.01)
          expect(project_data_to_replenish[1][:max_work_in_progress]).to eq 2
          expect(project_data_to_replenish[1][:throughput_data_size]).to eq 9
          expect(project_data_to_replenish[1][:customers_names]).to match_array second_project.customers.map(&:name)
          expect(project_data_to_replenish[1][:products_names]).to match_array second_project.products.map(&:name)

          expect(project_data_to_replenish[2][:id]).to eq third_project.id
          expect(project_data_to_replenish[2][:name]).to eq third_project.name
          expect(project_data_to_replenish[2][:start_date]).to eq third_project.start_date
          expect(project_data_to_replenish[2][:aging_today]).to eq 31
          expect(project_data_to_replenish[2][:end_date]).to eq third_project.end_date
          expect(project_data_to_replenish[2][:weeks_to_end_date]).to eq third_project.remaining_weeks
          expect(project_data_to_replenish[2][:remaining_backlog]).to eq third_project.remaining_backlog
          expect(project_data_to_replenish[2][:relative_flow_pressure]).to be_within(0.9).of(26.62)
          expect(project_data_to_replenish[2][:qty_using_pressure]).to be_within(0.1).of(0.5)
          expect(project_data_to_replenish[2][:leadtime_80]).to be_within(0.2).of(50_400.0)
          expect(project_data_to_replenish[2][:qty_selected_last_week]).to eq 0
          expect(project_data_to_replenish[2][:work_in_progress]).to eq 0
          expect(project_data_to_replenish[2][:montecarlo_80_percent]).to be_within(20).of(130)
          expect(project_data_to_replenish[2][:throughput_last_week]).to eq 1
          expect(project_data_to_replenish[2][:max_work_in_progress]).to eq 5
          expect(project_data_to_replenish[2][:throughput_data_size]).to eq 4
          expect(project_data_to_replenish[2][:customers_names]).to match_array third_project.customers.map(&:name)
          expect(project_data_to_replenish[2][:products_names]).to match_array third_project.products.map(&:name)
        end
      end
    end

    context 'with no data in the project' do
      it 'builds blank data' do
        other_team = Fabricate :team, company: company
        Fabricate :project, company: company, products: [product], customers: [customer], team: other_team, name: 'first_project', status: :executing, start_date: 4.months.ago, end_date: 2.weeks.from_now, max_work_in_progress: 3

        replenishing_data = described_class.new(other_team)

        expect(replenishing_data.summary_infos[:four_last_throughputs]).to be_nil
        project_data_to_replenish = replenishing_data.project_data_to_replenish
        expect(project_data_to_replenish[0][:qty_using_pressure]).to eq 0.0
      end
    end

    context 'with no data' do
      it 'builds blank data' do
        other_team = Fabricate :team, company: company

        replenishing_data = described_class.new(other_team)

        expect(replenishing_data.summary_infos[:four_last_throughputs]).to be_nil
        project_data_to_replenish = replenishing_data.project_data_to_replenish
        expect(project_data_to_replenish[0]).to be_nil
      end
    end

    context 'with only finished projects' do
      it 'builds blank data' do
        other_team = Fabricate :team, company: company
        project = Fabricate :project, company: company, products: [product], customers: [customer], team: other_team, name: 'first_project', status: :finished, start_date: 4.months.ago, end_date: 2.weeks.from_now, max_work_in_progress: 3
        Fabricate :demand, product: product, team: other_team, project: project, created_date: 4.months.ago, commitment_date: 3.months.ago, end_date: 2.months.ago

        replenishing_data = described_class.new(other_team)

        expect(replenishing_data.summary_infos[:four_last_throughputs]).to be_nil
        project_data_to_replenish = replenishing_data.project_data_to_replenish
        expect(project_data_to_replenish[0]).to be_nil
      end
    end
  end
end
