# frozen_string_literal: true

RSpec.describe StageAnalyticData, type: :data_object do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:project) { Fabricate :project, customers: [customer] }
  let(:stage) { Fabricate :stage, projects: [project] }
  let(:other_stage) { Fabricate :stage, projects: [project] }

  describe '.initialize' do
    context 'with transitions with duration' do
      subject(:stage_analytic_data) { described_class.new(stage) }

      let(:demand) { Fabricate :demand, project: project }
      let(:other_demand) { Fabricate :demand, project: project }

      it 'retrieves the last stages informations to the charts' do
        travel_to Time.zone.local(2018, 5, 29, 18, 25, 0) do
          Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 3.days.ago, last_time_out: 1.day.ago
          Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago, last_time_out: 1.hour.ago
          Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.now, last_time_out: 1.hour.from_now
          Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 4.days.ago, last_time_out: 1.day.ago
          Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: 1.hour.ago
          Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.now, last_time_out: 1.hour.from_now

          expect(stage_analytic_data.entrances_per_weekday).to eq({ 'Domingo' => { y: 1, color: 'rgb(247, 229, 83)' }, 'Segunda-feira' => { y: 1, color: 'rgb(73, 142, 142)' }, 'Terça-feira' => { y: 1, color: 'rgb(73, 142, 142)' }, 'Sexta-feira' => { y: 1, color: 'rgb(73, 142, 142)' }, 'Sábado' => { y: 1, color: 'rgb(73, 142, 142)' } })
          expect(stage_analytic_data.entrances_per_day.keys).to eq([25, 26, 27, 28.0, 29.0])
          expect(stage_analytic_data.entrances_per_day.values).to eq([{ y: 1, color: 'rgb(247, 229, 83)' }, { y: 1, color: 'rgb(73, 142, 142)' }, { y: 1, color: 'rgb(73, 142, 142)' }, { y: 1, color: 'rgb(73, 142, 142)' }, { y: 1, color: 'rgb(73, 142, 142)' }])
          expect(stage_analytic_data.entrances_per_hour.keys).to eq([21])
          expect(stage_analytic_data.entrances_per_hour.values).to eq([{ y: 5, color: 'rgb(247, 229, 83)' }])

          expect(stage_analytic_data.out_per_weekday).to eq('Segunda-feira' => { y: 2, color: 'rgb(73, 142, 142)' }, 'Terça-feira' => { y: 3, color: 'rgb(247, 229, 83)' })
          expect(stage_analytic_data.out_per_day.keys).to eq([28.0, 29.0])
          expect(stage_analytic_data.out_per_day.values).to eq([{ y: 2, color: 'rgb(73, 142, 142)' }, { y: 3, color: 'rgb(247, 229, 83)' }])
          expect(stage_analytic_data.out_per_hour.keys).to eq([20.0, 21.0, 22.0])
          expect(stage_analytic_data.out_per_hour.values).to eq([{ y: 2, color: 'rgb(247, 229, 83)' }, { y: 2, color: 'rgb(73, 142, 142)' }, { y: 1, color: 'rgb(73, 142, 142)' }])

          expect(stage_analytic_data.avg_time_in_stage_per_month).to eq('Maio/2018' => { y: 38.2 })
        end
      end
    end

    context 'with transitions without duration' do
      subject(:stage_analytic_data) { described_class.new(stage) }

      it 'retrieves the last stages informations to the charts' do
        travel_to Time.zone.local(2018, 5, 29, 18, 25, 0) do
          demand = Fabricate :demand, project: project
          Fabricate :demand, project: project

          Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago, last_time_out: nil
          Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: nil
          Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.now, last_time_out: nil

          expect(stage_analytic_data.entrances_per_weekday).to eq('Domingo' => { y: 1, color: 'rgb(247, 229, 83)' }, 'Segunda-feira' => { y: 1, color: 'rgb(73, 142, 142)' }, 'Terça-feira' => { y: 1, color: 'rgb(73, 142, 142)' })
          expect(stage_analytic_data.entrances_per_day.keys).to eq [27.0, 28.0, 29.0]
          expect(stage_analytic_data.entrances_per_day.values).to eq [{ y: 1, color: 'rgb(247, 229, 83)' }, { y: 1, color: 'rgb(73, 142, 142)' }, { y: 1, color: 'rgb(73, 142, 142)' }]
          expect(stage_analytic_data.entrances_per_hour.keys).to eq [21.0]
          expect(stage_analytic_data.entrances_per_hour.values).to eq [{ y: 3, color: 'rgb(247, 229, 83)' }]

          expect(stage_analytic_data.out_per_weekday).to eq({})
          expect(stage_analytic_data.out_per_day).to eq({})
          expect(stage_analytic_data.out_per_hour).to eq({})

          expect(stage_analytic_data.avg_time_in_stage_per_month).to eq('Maio/2018' => { y: 0 })
        end
      end
    end
  end
end
