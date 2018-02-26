# frozen_string_literal: true

RSpec.describe PipefyReader, type: :service do
  describe '#process_card' do
    let(:project) { Fabricate :project, start_date: Time.iso8601('2018-01-11T23:01:46-02:00'), end_date: Time.iso8601('2018-02-25T23:01:46-02:00') }
    let(:team) { Fabricate :team }
    let!(:stage) { Fabricate :stage, projects: [project], integration_id: '2481595', compute_effort: true }
    let!(:end_stage) { Fabricate :stage, projects: [project], integration_id: '2481597', compute_effort: false, end_point: true }

    let(:first_card_response) { { data: { card: { id: '4648391', title: 'teste 2', assignees: [], comments: [], comments_count: 0, current_phase: { name: 'Concluído' }, done: true, due_date: nil, fields: [{ name: 'O quê?', value: 'teste 2' }, { name: 'Type', value: 'Bug' }], phases_history: [{ phase: { id: '2481594', name: 'Start form', done: false, fields: [{ label: 'O quê?' }, { label: 'Type' }] }, lastTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-16T22:44:57-02:00' }, { phase: { id: '2481595', name: 'Caixa de entrada', done: false, fields: [{ label: 'Commitment Point' }] }, lastTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-17T23:01:46-02:00' }, { phase: { id: '2481596', name: 'Fazendo', done: false, fields: [{ label: 'Commitment Point' }] }, lastTimeIn: '2018-01-16T23:01:46-02:00', lastTimeOut: '2018-02-11T17:43:22-02:00' }, { phase: { id: '2481597', name: 'Concluído', done: true, fields: [] }, lastTimeIn: '2018-02-09T01:01:41-02:00', lastTimeOut: nil }], pipe: { id: '356528' }, url: 'http://app.pipefy.com/pipes/356528#cards/4648391' } } }.with_indifferent_access }
    let(:second_card_response) { { data: { card: { id: '4648389', title: 'teste 2', assignees: [], comments: [], comments_count: 0, current_phase: { name: 'Concluído' }, done: true, due_date: nil, fields: [{ name: 'O quê?', value: 'teste 2' }, { name: 'Type', value: 'Nova Funcionalidade' }], phases_history: [{ phase: { id: '2481595', name: 'Caixa de entrada', done: false, fields: [{ label: 'Commitment Point' }] }, lastTimeIn: '2018-02-09T01:01:41-02:00', lastTimeOut: '2018-02-11T01:01:41-02:00' }], pipe: { id: '356528' }, url: 'http://app.pipefy.com/pipes/356528#cards/4648389' } } }.with_indifferent_access }
    let(:third_card_response) { { data: { card: { id: '4648976', title: 'teste 2', assignees: [], comments: [], comments_count: 0, current_phase: { name: 'Concluído' }, done: true, due_date: nil, fields: [{ name: 'O quê?', value: 'teste 2' }, { name: 'Type', value: 'Chore' }], phases_history: [{ phase: { id: '2481595', name: 'Caixa de entrada', done: false, fields: [{ label: 'Commitment Point' }] }, lastTimeIn: '2018-02-09T01:01:41-02:00', lastTimeOut: '2018-02-11T01:01:41-02:00' }], pipe: { id: '356528' }, url: 'http://app.pipefy.com/pipes/356528#cards/4648976' } } }.with_indifferent_access }
    let(:pipe_response) { { data: { pipe: { phases: [{ cards: { edges: [{ node: { id: '4648389', title: 'ateste' } }] } }, { cards: { edges: [] } }, { cards: { edges: [{ node: { id: '4648391', title: 'teste 2' } }] } }] } } }.with_indifferent_access }

    context 'having no pipefy_config' do
      it 'processes the card creating or updating the models' do
        PipefyReader.instance.process_card(first_card_response)

        expect(Demand.count).to eq 0
      end
    end
    context 'having pipefy_config' do
      let!(:pipefy_config) { Fabricate :pipefy_config, project: project, team: team, pipe_id: '356528' }

      context 'when the demand exists' do
        context 'and the project result is in another date' do
          let!(:demand) { Fabricate :demand, project: project, project_result: nil, demand_id: '4648391' }
          let!(:project_result) { Fabricate :project_result, project: project, demands: [demand], result_date: '2018-01-12T01:01:41-02:00' }

          it 'processes the card creating the demand and project result' do
            PipefyReader.instance.process_card(first_card_response)

            expect(Demand.count).to eq 1
            expect(ProjectResult.count).to eq 2

            updated_result = ProjectResult.first
            expect(updated_result.result_date).to eq Date.new(2018, 1, 12)
            expect(updated_result.known_scope).to eq 0
            expect(updated_result.qty_hours_downstream).to eq 0
            expect(updated_result.qty_hours_upstream).to eq 0
            expect(updated_result.qty_hours_bug).to eq 0

            created_result = ProjectResult.second
            expect(created_result.result_date).to eq Date.new(2018, 2, 9)
            expect(created_result.known_scope).to eq 1
            expect(created_result.qty_hours_downstream).to eq 8
            expect(created_result.qty_hours_upstream).to eq 0
            expect(created_result.qty_hours_bug).to eq 8
          end
        end
        context 'and the project result is in the same date' do
          let!(:demand) { Fabricate :demand, project: project, project_result: nil, demand_id: '4648391' }
          let!(:project_result) { Fabricate :project_result, project: project, demands: [demand], result_date: '2018-02-09T01:01:41-02:00' }

          it 'processes the card creating the demand and project result' do
            PipefyReader.instance.process_card(first_card_response)

            expect(Demand.count).to eq 1
            expect(ProjectResult.count).to eq 1

            updated_result = ProjectResult.first
            expect(updated_result.result_date).to eq Date.new(2018, 2, 9)
            expect(updated_result.known_scope).to eq 1
            expect(updated_result.qty_hours_downstream).to eq 8
            expect(updated_result.qty_hours_upstream).to eq 0
            expect(updated_result.qty_hours_bug).to eq 8
          end
        end
      end

      context 'when the demand does not exist' do
        context 'when it is bug' do
          it 'processes the card creating the demand and project result' do
            PipefyReader.instance.process_card(first_card_response)
            created_demand = Demand.last
            expect(created_demand.bug?).to be true
            expect(created_demand.demand_id).to eq '4648391'
            expect(created_demand.effort.to_f).to eq 8.33333333333333
            expect(created_demand.url).to eq 'http://app.pipefy.com/pipes/356528#cards/4648391'
          end
        end

        context 'when it is feature' do
          it 'processes the card creating the demand and project result' do
            PipefyReader.instance.process_card(second_card_response)
            created_demand = Demand.last
            expect(created_demand.feature?).to be true
            expect(created_demand.demand_id).to eq '4648389'
            expect(created_demand.effort.to_f).to eq 7.66666666666667
            expect(created_demand.url).to eq 'http://app.pipefy.com/pipes/356528#cards/4648389'
          end
        end

        context 'when it is chore' do
          it 'processes the card creating the demand and project result' do
            PipefyReader.instance.process_card(third_card_response)
            created_demand = Demand.last
            expect(created_demand.chore?).to be true
            expect(created_demand.demand_id).to eq '4648976'
            expect(created_demand.effort.to_f).to eq 7.66666666666667
            expect(created_demand.url).to eq 'http://app.pipefy.com/pipes/356528#cards/4648976'
          end
        end
      end
    end
  end
end
