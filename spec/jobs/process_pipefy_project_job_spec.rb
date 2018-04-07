# frozen_string_literal: true

RSpec.describe ProcessPipefyProjectJob, type: :active_job do
  let(:team) { Fabricate :team }
  let(:project) { Fabricate :project, start_date: Time.zone.iso8601('2017-01-01T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-25T23:01:46-02:00') }
  let!(:stage) { Fabricate :stage, projects: [project], integration_id: '2481595', compute_effort: true }

  let(:headers) { { Authorization: "Bearer #{Figaro.env.pipefy_token}" } }
  let(:params) { { data: { action: 'card.done', done_by: { id: 101_381, name: 'Foo Bar', username: 'foo', email: 'foo@bar.com', avatar_url: 'gravatar' }, card: { id: 4_648_391, pipe_id: '5fc4VmAE' } } }.with_indifferent_access }

  let(:card_response) { { data: { card: { id: '4648391', title: 'teste 2', assignees: [], comments: [], comments_count: 0, current_phase: { name: 'Concluído' }, done: true, due_date: nil, fields: [{ name: 'O quê?', value: 'teste 2' }, { name: 'Type', value: 'Bug' }, { name: 'project', value: project.full_name }], labels: [{ name: 'BUG' }], phases_history: [{ phase: { id: '2481594', name: 'Start form', done: false, fields: [{ label: 'O quê?' }, { label: 'Type' }] }, lastTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-16T22:44:57-02:00' }, { phase: { id: '2481595', name: 'Caixa de entrada', done: false, fields: [{ label: 'Commitment Point' }] }, lastTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-17T23:01:46-02:00' }, { phase: { id: '2481596', name: 'Fazendo', done: false, fields: [{ label: 'Commitment Point' }] }, lastTimeIn: '2018-01-16T23:01:46-02:00', lastTimeOut: '2018-02-11T17:43:22-02:00' }, { phase: { id: '2481597', name: 'Concluído', done: true, fields: [] }, lastTimeIn: '2018-02-09T01:01:41-02:00', lastTimeOut: nil }], pipe: { id: '356528' }, url: 'http://app.pipefy.com/pipes/356528#cards/4648391' } } }.with_indifferent_access }
  let(:other_card_response) { { data: { card: { id: '4648389', title: 'teste 2', assignees: [], comments: [], comments_count: 0, current_phase: { name: 'Concluído' }, done: true, due_date: nil, fields: [{ name: 'O quê?', value: 'teste 2' }, { name: 'Type', value: 'Nova Funcionalidade' }, { name: 'project', value: project.full_name }], labels: [{ name: 'BUG' }], phases_history: [{ phase: { id: '2481595', name: 'Caixa de entrada', done: false, fields: [{ label: 'Commitment Point' }] }, lastTimeIn: '2018-02-09T01:01:41-02:00', lastTimeOut: '2018-02-11T01:01:41-02:00' }], pipe: { id: '356528' }, url: 'http://app.pipefy.com/pipes/356528#cards/4648389' } } }.with_indifferent_access }
  let(:pipe_response) { { data: { pipe: { phases: [{ id: '2481594' }, { id: '2481595' }, { id: '2481596' }, { id: '2481597' }] } } }.with_indifferent_access }

  let(:phase_response) { { data: { phase: { cards: { pageInfo: { endCursor: 'WzUxNDEwNDdd', hasNextPage: false }, edges: [{ node: { id: '4648391' } }, { node: { id: '4648389' } }] } } } }.with_indifferent_access }

  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      ProcessPipefyProjectJob.perform_later(project)
      expect(ProcessPipefyProjectJob).to have_been_enqueued.on_queue('default')
    end
  end

  context 'having no pipefy_config' do
    it 'returns doing nothing' do
      expect(Pipefy::PipefyApiService).to receive(:request_card_details).never
      ProcessPipefyProjectJob.perform_now(project)
    end
  end

  context 'having params' do
    context 'and a pipefy config' do
      let!(:pipefy_config) { Fabricate :pipefy_config, project: project, team: team, pipe_id: '356528' }
      let(:project_result) { Fabricate :project_result, project: project, result_date: Time.zone.iso8601('2017-01-02T23:01:46-02:00') }
      let!(:first_demand) { Fabricate :demand, project: project, project_result: project_result, demand_id: '4648391' }
      let!(:second_demand) { Fabricate :demand, project: project, project_result: project_result, demand_id: '4648389' }

      context 'returning success' do
        before do
          stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648391/).to_return(status: 200, body: card_response.to_json, headers: {})
          stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648389/).to_return(status: 200, body: other_card_response.to_json, headers: {})
          stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481595/).to_return(status: 200, body: phase_response.to_json, headers: {})
        end

        it 'calls the methods to update the demand' do
          expect(Pipefy::PipefyResponseReader.instance).to(receive(:create_card!).with(project, team, card_response).once { first_demand })
          expect(Pipefy::PipefyResponseReader.instance).to(receive(:create_card!).with(project, team, other_card_response).once { second_demand })
          expect(Pipefy::PipefyResponseReader.instance).to receive(:update_card!).with(project, team, first_demand, card_response).once
          expect(Pipefy::PipefyResponseReader.instance).to receive(:update_card!).with(project, team, second_demand, other_card_response).once
          expect_any_instance_of(ProjectResult).to receive(:compute_flow_metrics!).once
          ProcessPipefyProjectJob.perform_now(project)
        end
      end
    end
  end
end
