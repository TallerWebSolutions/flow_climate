# frozen_string_literal: true

RSpec.describe DemandTransition, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:demand) }
    it { is_expected.to belong_to(:stage) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :demand }
      it { is_expected.to validate_presence_of :stage }
      it { is_expected.to validate_presence_of :last_time_in }
    end

    context 'complex ones' do
      context 'same_stage_project?' do
        let(:project) { Fabricate :project }
        let!(:stage) { Fabricate :stage, stage_stream: :downstream, projects: [project] }
        let!(:other_stage) { Fabricate :stage, stage_stream: :upstream }
        let(:demand) { Fabricate :demand, project: project }

        context 'having the same stage' do
          let(:demand_transition) { Fabricate.build :demand_transition, stage: stage, demand: demand }
          it { expect(demand_transition.valid?).to be true }
        end

        context 'having other stage' do
          let(:demand_transition) { Fabricate.build :demand_transition, stage: stage }
          it 'responds invalid' do
            expect(demand_transition.valid?).to be false
            expect(demand_transition.errors[:stage]).to eq ['A etapa deve ser a mesma do projeto da demanda']
          end
        end
      end
    end
  end

  context 'scopes' do
    describe '.downstream_transitions' do
      let(:project) { Fabricate :project }
      let!(:stage) { Fabricate :stage, stage_stream: :downstream, projects: [project] }
      let(:other_stage) { Fabricate :stage, stage_stream: :upstream, projects: [project] }
      let!(:end_stage) { Fabricate :stage, stage_stream: :downstream, projects: [project], end_point: true }
      let(:demand) { Fabricate :demand, project: project }

      context 'having data' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage }
        let!(:other_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage }
        let!(:done_downstream_transition) { Fabricate :demand_transition, demand: demand, stage: end_stage }
        let!(:upstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage }

        it { expect(DemandTransition.downstream_transitions).to match_array [demand_transition, other_demand_transition] }
      end
      context 'having no data' do
        it { expect(DemandTransition.downstream_transitions).to match_array [] }
      end
    end
    describe '.upstream_transitions' do
      let(:project) { Fabricate :project }
      let!(:stage) { Fabricate :stage, stage_stream: :downstream, projects: [project] }
      let(:other_stage) { Fabricate :stage, stage_stream: :upstream, projects: [project] }
      let(:demand) { Fabricate :demand, project: project }

      context 'having data' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage }
        let!(:other_demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage }
        let!(:upstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage }

        it { expect(DemandTransition.upstream_transitions).to match_array [demand_transition, other_demand_transition] }
      end
      context 'having no data' do
        it { expect(DemandTransition.upstream_transitions).to eq [] }
      end
    end

    describe '.touch_transitions' do
      let(:project) { Fabricate :project }

      let!(:queue_stage) { Fabricate :stage, stage_stream: :downstream, queue: true, projects: [project] }
      let!(:touch_stage) { Fabricate :stage, stage_stream: :downstream, queue: false, projects: [project] }
      let(:other_touch_stage) { Fabricate :stage, stage_stream: :upstream, queue: false, projects: [project] }
      let(:out_stream_touch_stage) { Fabricate :stage, stage_stream: :out_stream, queue: false, projects: [project] }

      let(:demand) { Fabricate :demand, project: project }

      context 'having data' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: queue_stage }
        let!(:touch_transition) { Fabricate :demand_transition, demand: demand, stage: touch_stage }
        let!(:other_touch_transition) { Fabricate :demand_transition, demand: demand, stage: other_touch_stage }

        let!(:out_stream_touch_transition) { Fabricate :demand_transition, demand: demand, stage: out_stream_touch_stage }

        it { expect(DemandTransition.touch_transitions).to match_array [touch_transition, other_touch_transition] }
      end
      context 'having no data' do
        it { expect(DemandTransition.touch_transitions).to eq [] }
      end
    end

    describe '.queue_transitions' do
      let(:project) { Fabricate :project }

      let!(:touch_stage) { Fabricate :stage, stage_stream: :downstream, queue: false, projects: [project] }
      let!(:queue_stage) { Fabricate :stage, stage_stream: :downstream, queue: true, projects: [project] }
      let(:other_queue_stage) { Fabricate :stage, stage_stream: :upstream, queue: true, projects: [project] }
      let(:out_stream_queue_stage) { Fabricate :stage, stage_stream: :out_stream, queue: true, projects: [project] }

      let(:demand) { Fabricate :demand, project: project }

      context 'having data' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: touch_stage }
        let!(:queue_transition) { Fabricate :demand_transition, demand: demand, stage: queue_stage }
        let!(:other_queue_transition) { Fabricate :demand_transition, demand: demand, stage: other_queue_stage }

        let!(:out_stream_touch_transition) { Fabricate :demand_transition, demand: demand, stage: out_stream_queue_stage }

        it { expect(DemandTransition.queue_transitions).to match_array [queue_transition, other_queue_transition] }
      end
      context 'having no data' do
        it { expect(DemandTransition.queue_transitions).to eq [] }
      end
    end

    pending '.effort_transitions_to_project'
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:stage).with_prefix }
    it { is_expected.to delegate_method(:compute_effort).to(:stage).with_prefix }
  end

  describe '#set_demand_dates' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }

    context 'when the stage is a commitment_point' do
      let(:stage) { Fabricate :stage, company: company, commitment_point: true, end_point: false, projects: [project] }
      let(:demand) { Fabricate :demand, project: project, created_date: Time.zone.parse('2018-02-04 12:00:00'), end_date: nil }
      let(:transition_date) { Time.zone.parse('2018-03-13 12:00:00') }

      before { Fabricate :demand_transition, stage: stage, demand: demand, last_time_in: transition_date }
      it 'sets the commitment date and do not touch in the others' do
        expect(demand.reload.commitment_date).to eq transition_date
        expect(demand.reload.created_date).to eq Time.zone.parse('2018-02-04 12:00:00')
        expect(demand.reload.end_date).to be_nil
      end
    end
    context 'when the stage is an end_point' do
      let!(:first_stage) { Fabricate :stage, company: company, commitment_point: false, end_point: true, projects: [project], order: 0, integration_pipe_id: '123', stage_stream: :downstream }
      let!(:second_stage) { Fabricate :stage, company: company, commitment_point: false, end_point: true, projects: [project], order: 1, integration_pipe_id: '123', stage_stream: :downstream }

      context 'and there is no end_date defined' do
        let(:demand) { Fabricate :demand, project: project, created_date: Time.zone.parse('2018-02-04 12:00:00'), commitment_date: nil }
        let(:transition_date) { Time.zone.parse('2018-03-13 12:00:00') }

        before { Fabricate :demand_transition, stage: first_stage, demand: demand, last_time_in: transition_date }
        it 'sets the end_date and do not touch in the others' do
          expect(demand.reload.commitment_date).to be_nil
          expect(demand.reload.created_date).to eq Time.zone.parse('2018-02-04 12:00:00')
          expect(demand.reload.end_date).to eq transition_date
        end
      end
      context 'and there is an end_date defined by a previous stage' do
        let(:demand) { Fabricate :demand, project: project, created_date: Time.zone.parse('2018-02-04 12:00:00'), commitment_date: nil, end_date: Time.zone.parse('2018-02-05 12:00:00') }
        let(:transition_date) { Time.zone.parse('2018-03-13 12:00:00') }

        before { Fabricate :demand_transition, stage: second_stage, demand: demand, last_time_in: transition_date }
        it 'do not touch the dates' do
          expect(demand.reload.commitment_date).to be_nil
          expect(demand.reload.created_date).to eq Time.zone.parse('2018-02-04 12:00:00')
          expect(demand.reload.end_date).to eq Time.zone.parse('2018-02-05 12:00:00')
        end
      end
    end
    context 'when the stage is a wip and the demand has end_date' do
      context 'and the stage of the transition is before the end_point' do
        let!(:stage) { Fabricate :stage, company: company, commitment_point: false, end_point: false, projects: [project], order: 0 }
        let!(:other_stage) { Fabricate :stage, company: company, commitment_point: false, end_point: true, projects: [project], order: 1 }

        let(:demand) { Fabricate :demand, project: project, created_date: Time.zone.parse('2018-02-04 12:00:00'), commitment_date: nil, end_date: 2.weeks.from_now }
        let(:transition_date) { Time.zone.parse('2018-03-13 12:00:00') }

        before { Fabricate :demand_transition, stage: stage, demand: demand, last_time_in: transition_date }
        it 'sets the commitment date and do not touch in the others' do
          expect(demand.reload.commitment_date).to be_nil
          expect(demand.reload.created_date).to eq Time.zone.parse('2018-02-04 12:00:00')
          expect(demand.reload.end_date).to be_nil
        end
      end

      context 'and the stage of the transition is after the end_point' do
        let!(:stage) { Fabricate :stage, company: company, commitment_point: false, end_point: false, projects: [project], integration_pipe_id: '123', order: 1, stage_stream: :downstream }
        let!(:other_stage) { Fabricate :stage, company: company, commitment_point: false, end_point: true, projects: [project], integration_pipe_id: '123', order: 0, stage_stream: :downstream }

        let(:demand) { Fabricate :demand, project: project, created_date: Time.zone.parse('2018-02-04 12:00:00'), commitment_date: nil, end_date: 2.weeks.from_now }
        let(:transition_date) { Time.zone.parse('2018-03-13 12:00:00') }

        before { Fabricate :demand_transition, stage: stage, demand: demand, last_time_in: transition_date }
        it 'sets the commitment date and do not touch in the others' do
          expect(demand.reload.commitment_date).to be_nil
          expect(demand.reload.created_date).to eq Time.zone.parse('2018-02-04 12:00:00')
          expect(demand.reload.end_date).not_to be_nil
        end
      end
    end
  end

  describe '#total_seconds_in_transition' do
    let(:project) { Fabricate :project }
    let(:stage) { Fabricate :stage, commitment_point: true, end_point: false, queue: false, stage_stream: :downstream, projects: [project] }
    let(:demand) { Fabricate :demand, project: project, created_date: Time.zone.parse('2018-02-04 12:00:00') }

    context 'when there is last_time_out' do
      let!(:demand_transition) { Fabricate :demand_transition, stage: stage, demand: demand, last_time_in: Time.zone.parse('2018-03-15 12:00:00'), last_time_out: Time.zone.parse('2018-03-19 12:00:00') }
      let!(:other_demand_transition) { Fabricate :demand_transition, stage: stage, demand: demand, last_time_in: Time.zone.parse('2018-03-17 12:00:00'), last_time_out: Time.zone.parse('2018-03-19 12:00:00') }

      it 'compute the correct fields' do
        expect(demand_transition.total_seconds_in_transition / 1.day).to eq 4
        expect(other_demand_transition.total_seconds_in_transition / 1.day).to eq 2
        expect(demand.total_touch_time / 1.day).to eq 6
      end
    end

    context 'when there is no last_time_out' do
      let(:demand_transition) { Fabricate :demand_transition, stage: stage, demand: demand, last_time_in: Time.zone.parse('2018-03-13 12:00:00'), last_time_out: nil }
      it { expect(demand_transition.total_seconds_in_transition).to eq 0 }
    end
  end

  describe '#working_time_in_transition' do
    let(:project) { Fabricate :project }
    let(:stage) { Fabricate :stage, commitment_point: true, end_point: false, projects: [project] }
    let(:demand) { Fabricate :demand, project: project, created_date: Time.zone.parse('2018-02-04 12:00:00') }

    context 'when there is last_time_out' do
      let(:demand_transition) { Fabricate :demand_transition, stage: stage, demand: demand, last_time_in: Time.zone.parse('2018-03-15 12:00:00'), last_time_out: Time.zone.parse('2018-03-19 12:00:00') }
      it { expect(demand_transition.working_time_in_transition).to eq 12 }
    end
    context 'when there is no last_time_out' do
      let(:demand_transition) { Fabricate :demand_transition, stage: stage, demand: demand, last_time_in: Time.zone.parse('2018-03-13 12:00:00'), last_time_out: nil }
      it { expect(demand_transition.working_time_in_transition).to eq 0 }
    end
  end
end
