# frozen_string_literal: true

RSpec.describe Highchart::TasksChartsAdapter do
  describe '.initialize' do
    context 'with data' do
      it 'creates the data sctructure to the highchart' do
        travel_to Time.zone.local(2022, 1, 26, 10, 0, 0) do
          Fabricate :task, created_date: 3.weeks.ago, end_date: 2.weeks.ago
          Fabricate :task, created_date: 2.weeks.ago, end_date: 1.week.ago
          Fabricate :task, created_date: 1.week.ago

          allow(Task).to(receive(:where)).and_return(Task.all)
          task_chart = described_class.new(Task.all.map(&:id), 3.weeks.ago, 3.weeks.from_now)

          expect(task_chart.x_axis).to eq TimeService.instance.weeks_between_of(3.weeks.ago, 3.weeks.from_now)
          expect(task_chart.tasks_in_chart.map(&:id)).to match_array Task.all.map(&:id)
          expect(task_chart.creation_chart_data).to eq [1, 1, 1, 0]
          expect(task_chart.throughput_chart_data).to eq [0, 1, 1, 0]
        end
      end
    end

    context 'without data' do
      it 'creates the data sctructure to the highchart with null values' do
        travel_to Time.zone.local(2022, 1, 26, 10, 0, 0) do
          allow(Task).to(receive(:where)).and_return(Task.none)
          task_chart = described_class.new(Task.all.map(&:id), 3.weeks.ago, 3.weeks.from_now)

          expect(task_chart.x_axis).to eq nil
          expect(task_chart.tasks_in_chart).to eq nil
          expect(task_chart.creation_chart_data).to eq nil
          expect(task_chart.throughput_chart_data).to eq nil
        end
      end
    end
  end
end
