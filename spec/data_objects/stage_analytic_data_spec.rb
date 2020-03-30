# frozen_string_literal: true

RSpec.describe StageAnalyticData, type: :data_object do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:project) { Fabricate :project, customers: [customer] }
  let(:stage) { Fabricate :stage, projects: [project] }
  let(:other_stage) { Fabricate :stage, projects: [project] }

  describe '.initialize' do
    before { travel_to Time.zone.local(2018, 5, 29, 18, 25, 0) }

    after { travel_back }

    context 'and the stage has transitions with duration' do
      subject(:stage_analytic_data) { described_class.new(stage) }

      let(:demand) { Fabricate :demand, project: project }
      let(:other_demand) { Fabricate :demand, project: project }

      let!(:first_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 3.days.ago, last_time_out: 1.day.ago }
      let!(:second_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago, last_time_out: 1.hour.ago }
      let!(:third_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.now, last_time_out: 1.hour.from_now }

      let!(:fourth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 4.days.ago, last_time_out: 1.day.ago }
      let!(:fifth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: 1.hour.ago }
      let!(:sixth_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.now, last_time_out: 1.hour.from_now }

      it 'retrieves the last stages informations to the charts' do
        expect(stage_analytic_data.entrances_per_weekday).to eq({ 'Domingo' => { y: 1, color: 'rgb(247, 229, 83)' }, 'Segunda-feira' => { y: 1, color: 'rgb(73, 142, 142)' }, 'Terça-feira' => { y: 1, color: 'rgb(73, 142, 142)' }, 'Sexta-feira' => { y: 1, color: 'rgb(73, 142, 142)' }, 'Sábado' => { y: 1, color: 'rgb(73, 142, 142)' } })
        expect(stage_analytic_data.entrances_per_day).to eq({ 25.0 => { y: 1, color: 'rgb(247, 229, 83)' }, 26.0 => { y: 1, color: 'rgb(73, 142, 142)' }, 27.0 => { y: 1, color: 'rgb(73, 142, 142)' }, 28.0 => { y: 1, color: 'rgb(73, 142, 142)' }, 29.0 => { y: 1, color: 'rgb(73, 142, 142)' } })
        expect(stage_analytic_data.entrances_per_hour).to eq({ 21.0 => { y: 5, color: 'rgb(247, 229, 83)' } })

        expect(stage_analytic_data.out_per_weekday).to eq('Segunda-feira' => { y: 2, color: 'rgb(73, 142, 142)' }, 'Terça-feira' => { y: 3, color: 'rgb(247, 229, 83)' })
        expect(stage_analytic_data.out_per_day).to eq(28.0 => { y: 2, color: 'rgb(73, 142, 142)' }, 29.0 => { y: 3, color: 'rgb(247, 229, 83)' })
        expect(stage_analytic_data.out_per_hour).to eq(20.0 => { y: 2, color: 'rgb(247, 229, 83)' }, 21.0 => { y: 2, color: 'rgb(73, 142, 142)' }, 22.0 => { y: 1, color: 'rgb(73, 142, 142)' })

        expect(stage_analytic_data.avg_time_in_stage_per_month).to eq('Maio/2018' => { y: 38.2 })
      end
    end

    context 'and the stage has transitions without duration' do
      subject(:stage_analytic_data) { described_class.new(stage) }

      let(:demand) { Fabricate :demand, project: project }
      let(:other_demand) { Fabricate :demand, project: project }

      let!(:first_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago, last_time_out: nil }
      let!(:second_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: nil }
      let!(:third_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.now, last_time_out: nil }

      it 'retrieves the last stages informations to the charts' do
        expect(stage_analytic_data.entrances_per_weekday).to eq('Domingo' => { y: 1, color: 'rgb(247, 229, 83)' }, 'Segunda-feira' => { y: 1, color: 'rgb(73, 142, 142)' }, 'Terça-feira' => { y: 1, color: 'rgb(73, 142, 142)' })
        expect(stage_analytic_data.entrances_per_day).to eq(27.0 => { y: 1, color: 'rgb(247, 229, 83)' }, 28.0 => { y: 1, color: 'rgb(73, 142, 142)' }, 29.0 => { y: 1, color: 'rgb(73, 142, 142)' })
        expect(stage_analytic_data.entrances_per_hour).to eq(21.0 => { y: 3, color: 'rgb(247, 229, 83)' })

        expect(stage_analytic_data.out_per_weekday).to eq({})
        expect(stage_analytic_data.out_per_day).to eq({})
        expect(stage_analytic_data.out_per_hour).to eq({})

        expect(stage_analytic_data.avg_time_in_stage_per_month).to eq('Maio/2018' => { y: 0 })
      end
    end
  end
end
