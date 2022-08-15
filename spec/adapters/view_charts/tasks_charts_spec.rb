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

  describe '#tasks_by_type' do
    context 'with data' do
      it 'computes and extracts the information of the demands count' do
        work_item_type = Fabricate :work_item_type, name: 'foo'
        other_work_item_type = Fabricate :work_item_type, name: 'bar'

        Fabricate :task, work_item_type: work_item_type
        Fabricate :task, work_item_type: work_item_type
        Fabricate :task, work_item_type: other_work_item_type
        Fabricate :task, work_item_type: other_work_item_type
        Fabricate :task, work_item_type: other_work_item_type

        tasks_chart_adapter = described_class.new(Task.all, 3.weeks.ago, 3.weeks.from_now, 'week')

        expect(tasks_chart_adapter.tasks_by_type).to eq([{ label: 'bar', value: 3 }, { label: 'foo', value: 2 }])
      end
    end

    context 'without data' do
      subject(:tasks_by_type) { described_class.new(Task.none, 3.weeks.ago, 3.weeks.from_now, 'week').tasks_by_type }

      it { expect(tasks_by_type).to eq [] }
    end
  end

  describe '#tasks_by_project' do
    context 'with data' do
      it 'computes and extracts the information of the tasks count' do
        project = Fabricate :project, name: 'foo'
        other_project = Fabricate :project, name: 'bar'

        demand = Fabricate :demand, project: project
        other_demand = Fabricate :demand, project: other_project

        Fabricate :task, demand: demand
        Fabricate :task, demand: demand
        Fabricate :task, demand: demand
        Fabricate :task, demand: other_demand
        Fabricate :task, demand: other_demand

        tasks_by_project = described_class.new(Task.all, 3.weeks.ago, 3.weeks.from_now, 'week').tasks_by_project

        expect(tasks_by_project).to eq([{ label: 'foo', value: 3 }, { label: 'bar', value: 2 }])
      end
    end

    context 'with no data' do
      subject(:tasks_by_project) { described_class.new(Task.none, 3.weeks.ago, 3.weeks.from_now, 'week').tasks_by_project }

      it { expect(tasks_by_project).to eq([]) }
    end
  end
end
