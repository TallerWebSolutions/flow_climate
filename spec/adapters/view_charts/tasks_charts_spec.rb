# frozen_string_literal: true

RSpec.describe ViewCharts::TasksCharts do
  describe '.initialize' do
    context 'with data' do
      context 'with weekly period' do
        it 'creates the data sctructure' do
          travel_to Time.zone.local(2022, 1, 26, 10, 0, 0) do
            Fabricate :task, created_date: 3.weeks.ago, end_date: 2.weeks.ago
            Fabricate :task, created_date: 2.weeks.ago, end_date: 1.week.ago
            Fabricate :task, created_date: 1.week.ago

            allow(Task).to(receive(:where)).and_return(Task.all)
            task_chart = described_class.new(Task.all.map(&:id), 3.weeks.ago, 3.weeks.from_now, 'WEEKLY')

            expect(task_chart.x_axis).to eq TimeService.instance.weeks_between_of(3.weeks.ago, 3.weeks.from_now)
            expect(task_chart.creation_array).to eq [1, 1, 1, 0]
            expect(task_chart.throughput_array).to eq [0, 1, 1, 0]
            expect(task_chart.completion_percentiles_on_time_array).to eq [0, 604_800.0, 604_800.0, 0, 0, 0, 0]
            expect(task_chart.accumulated_completion_percentiles_on_time_array).to eq [0, 604_800.0, 604_800.0, 604_800.0, 604_800.0, 604_800.0, 604_800.0]
          end
        end
      end

      context 'with dayly period' do
        it 'creates the data sctructure' do
          travel_to Time.zone.local(2022, 1, 26, 10, 0, 0) do
            Fabricate :task, created_date: 3.days.ago, end_date: 2.days.ago
            Fabricate :task, created_date: 2.days.ago, end_date: 1.day.ago
            Fabricate :task, created_date: 1.day.ago

            allow(Task).to(receive(:where)).and_return(Task.all)
            task_chart = described_class.new(Task.all.map(&:id), 3.days.ago, 3.days.from_now, 'DAILY')

            expect(task_chart.x_axis).to eq TimeService.instance.days_between_of(3.days.ago, 3.days.from_now)
            expect(task_chart.creation_array).to eq [1, 1, 1, 0, 0]
            expect(task_chart.throughput_array).to eq [0, 1, 1, 0, 0]
            expect(task_chart.completion_percentiles_on_time_array).to eq [0, 86_400.0, 86_400.0, 0, 0, 0, 0]
            expect(task_chart.accumulated_completion_percentiles_on_time_array).to eq [0, 86_400.0, 86_400.0, 86_400.0, 86_400.0, 86_400.0, 86_400.0]
          end
        end
      end

      context 'with monthly period' do
        it 'creates the data sctructure' do
          travel_to Time.zone.local(2022, 1, 26, 10, 0, 0) do
            Fabricate :task, created_date: 3.months.ago, end_date: 2.months.ago
            Fabricate :task, created_date: 2.months.ago, end_date: 1.month.ago
            Fabricate :task, created_date: 1.month.ago

            allow(Task).to(receive(:where)).and_return(Task.all)
            task_chart = described_class.new(Task.all.map(&:id), 3.months.ago, 3.months.from_now, 'MONTHLY')

            expect(task_chart.x_axis).to eq TimeService.instance.months_between_of(3.months.ago, 3.months.from_now)
            expect(task_chart.creation_array).to eq [1, 1, 1, 0]
            expect(task_chart.throughput_array).to eq [0, 1, 1, 0]
            expect(task_chart.completion_percentiles_on_time_array).to eq [0, 2_678_400.0, 2_592_000.0, 0, 0, 0, 0]
            expect(task_chart.accumulated_completion_percentiles_on_time_array).to eq [0, 2_678_400.0, 2_661_120.0, 2_661_120.0, 2_661_120.0, 2_661_120.0, 2_661_120.0]
          end
        end
      end
    end

    context 'without data' do
      it 'creates the data sctructure with null values' do
        travel_to Time.zone.local(2022, 1, 26, 10, 0, 0) do
          allow(Task).to(receive(:where)).and_return(Task.none)
          task_chart = described_class.new(Task.all.map(&:id), 3.weeks.ago, 3.weeks.from_now, 'WEEKLY')

          expect(task_chart.x_axis).to eq []
          expect(task_chart.creation_array).to eq []
          expect(task_chart.throughput_array).to eq []
          expect(task_chart.completion_percentiles_on_time_array).to eq []
          expect(task_chart.accumulated_completion_percentiles_on_time_array).to eq []
        end
      end
    end
  end
end
