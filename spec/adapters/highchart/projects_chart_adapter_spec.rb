# frozen_string_literal: true

RSpec.describe Highchart::ProjectsChartAdapter, type: :adapter do
  let(:company) { Fabricate :company }
  let(:team) { Fabricate :team, company: company }

  describe '#hours_per_project_in_period' do
    context 'with projects' do
      it 'returns the hours distribution in the period' do
        travel_to Date.new(2021, 4, 18) do
          first_project = Fabricate :project, team: team, start_date: 6.months.ago, end_date: 4.months.ago
          second_project = Fabricate :project, team: team, start_date: 5.months.ago, end_date: Time.zone.today

          Fabricate :project_consolidation, project: first_project, consolidation_date: 7.months.ago.end_of_month, project_throughput_hours_in_month: 103
          Fabricate :project_consolidation, project: first_project, consolidation_date: 6.months.ago.end_of_month, project_throughput_hours_in_month: 10
          Fabricate :project_consolidation, project: first_project, consolidation_date: 5.months.ago.end_of_month, project_throughput_hours_in_month: 12
          Fabricate :project_consolidation, project: first_project, consolidation_date: first_project.end_date, project_throughput_hours_in_month: 21
          Fabricate :project_consolidation, project: second_project, consolidation_date: 5.months.ago.end_of_month, project_throughput_hours_in_month: 15

          chart_adapter = described_class.new([first_project, second_project])

          expect(chart_adapter.hours_per_project_in_period(6.months.ago.to_date.end_of_month, Time.zone.today.end_of_month)).to match_array({ x_axis: %w[Out/2020 Nov/2020 Dez/2020 Jan/2021 Fev/2021 Mar/2021 Abr/2021], data: { first_project.name => [10, 12, 21, 0, 0, 0, 0], second_project.name => [0, 15, 0, 0, 0, 0, 0] } })
        end
      end
    end

    context 'with no consolidations' do
      it 'returns the hours distribution in the period' do
        travel_to Date.new(2021, 4, 18) do
          first_project = Fabricate :project, team: team, start_date: 6.months.ago
          second_project = Fabricate :project, team: team, start_date: 5.months.ago

          chart_adapter = described_class.new([first_project, second_project])

          expect(chart_adapter.hours_per_project_in_period(6.months.ago, Time.zone.today)).to eq({ x_axis: %w[Out/2020 Nov/2020 Dez/2020 Jan/2021 Fev/2021 Mar/2021 Abr/2021], data: { first_project.name => [0, 0, 0, 0, 0, 0, 0], second_project.name => [0, 0, 0, 0, 0, 0, 0] } })
        end
      end
    end

    context 'with no projects' do
      it 'returns the hours distribution in the period' do
        travel_to Date.new(2021, 4, 18) do
          chart_adapter = described_class.new([])

          expect(chart_adapter.hours_per_project_in_period(6.months.ago, Time.zone.today)).to eq({ x_axis: %w[Out/2020 Nov/2020 Dez/2020 Jan/2021 Fev/2021 Mar/2021 Abr/2021], data: {} })
        end
      end
    end
  end
end
