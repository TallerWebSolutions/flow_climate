# frozen_string_literal: true

RSpec.describe ProcessPipefyCardJob, type: :active_job do
  describe '.perform' do
    it 'enqueues after calling perform_later' do
      ProcessPipefyCardJob.perform_later(bla: 'foo')
      expect(ProcessPipefyCardJob).to have_been_enqueued.on_queue('default')
    end
  end

  context 'having no params' do
    it 'returns doing nothing' do
      expect(Pipefy::PipefyResponseReader.instance).to receive(:create_card!).never
      ProcessPipefyCardJob.perform_now({})
    end
  end
  context 'having params' do
    let(:project) { Fabricate :project, end_date: Time.zone.iso8601('2018-02-16T23:01:46-02:00') }
    let!(:project_result) { Fabricate :project_result, project: project, result_date: Time.zone.iso8601('2018-02-16T23:01:46-02:00') }
    let!(:other_project_result) { Fabricate :project_result }
    let(:card_response) { { data: { card: { id: '4648391', title: 'teste 2', assignees: [], comments: [], comments_count: 0, current_phase: { name: 'Concluído' }, done: true, due_date: nil, fields: [{ name: 'O quê?', value: 'teste 2' }, { name: 'Type', value: 'Bug' }, { name: 'project', value: project.full_name }], labels: [{ name: 'BUG' }], phases_history: [{ phase: { id: '2481594', name: 'Start form', done: false, fields: [{ label: 'O quê?' }, { label: 'Type' }] }, lastTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-16T22:44:57-02:00' }, { phase: { id: '2481595', name: 'Caixa de entrada', done: false, fields: [{ label: 'Commitment Point' }] }, lastTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-17T23:01:46-02:00' }, { phase: { id: '2481596', name: 'Fazendo', done: false, fields: [{ label: 'Commitment Point' }] }, lastTimeIn: '2018-01-16T23:01:46-02:00', lastTimeOut: '2018-02-11T17:43:22-02:00' }, { phase: { id: '2481597', name: 'Concluído', done: true, fields: [] }, lastTimeIn: '2018-02-09T01:01:41-02:00', lastTimeOut: nil }], pipe: { id: '356528' }, url: 'http://app.pipefy.com/pipes/356528#cards/4648391' } } }.with_indifferent_access }
    let(:pipe_response) { { data: { pipe: { phases: [{ cards: { edges: [{ node: { id: '4648389', title: 'ateste' } }] } }, { cards: { edges: [] } }, { cards: { edges: [{ node: { id: '4648391', title: 'teste 2' } }] } }] } } }.with_indifferent_access }
    let(:headers) { { Authorization: "Bearer #{Figaro.env.pipefy_token}" } }
    let(:params) { { data: { action: 'card.done', done_by: { id: 101_381, name: 'Foo Bar', username: 'foo', email: 'foo@bar.com', avatar_url: 'gravatar' }, card: { id: 4_648_391, pipe_id: '5fc4VmAE' } } }.with_indifferent_access }

    before do
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648391/).to_return(status: 200, body: card_response.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /356528/).to_return(status: 200, body: pipe_response.to_json, headers: {})
    end

    let!(:stage) { Fabricate :stage, projects: [project], integration_id: '2481595', compute_effort: true }
    let!(:end_stage) { Fabricate :stage, projects: [project], integration_id: '2481597', compute_effort: false, end_point: true }

    let(:team) { Fabricate :team }

    context 'and a pipefy config' do
      let!(:pipefy_config) { Fabricate :pipefy_config, project: project, team: team, pipe_id: '356528' }
      context 'and demand' do
        let!(:demand) { Fabricate :demand, project: project, project_result: project_result }
        it 'updates the demand and the project result' do
          expect(Pipefy::PipefyResponseReader.instance).to(receive(:create_card!).with(project, team, card_response).once { demand })
          expect(Pipefy::PipefyResponseReader.instance).to receive(:update_card!).with(project, team, demand, card_response).once
          expect(project).to receive(:project_results) { [project_result] }
          expect(project_result).to receive(:compute_flow_metrics!).once
          ProcessPipefyCardJob.perform_now(params)
        end
      end
      context 'and no demand' do
        it 'updates the demand and the project result' do
          expect(Pipefy::PipefyResponseReader.instance).to receive(:create_card!).with(project, team, card_response).once
          expect(Pipefy::PipefyResponseReader.instance).to receive(:update_card!).never
          ProcessPipefyCardJob.perform_now(params)
        end
      end
    end

    context 'and no pipefy config' do
      it 'updates the demand and the project result' do
        expect(Pipefy::PipefyResponseReader.instance).to receive(:create_card!).with(project, team, card_response).never
        ProcessPipefyCardJob.perform_now(params)
      end
    end
  end
end
