# frozen_string_literal: true

RSpec.describe ProcessPipefyPipeJob, type: :active_job do
  let(:team) { Fabricate :team }
  let(:project) { Fabricate :project, start_date: Time.zone.iso8601('2017-01-01T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-25T23:01:46-02:00') }
  let!(:stage) { Fabricate :stage, projects: [project], integration_id: '2481595', compute_effort: true }
  let!(:end_stage) { Fabricate :stage, projects: [project], integration_id: '2481597', compute_effort: false, end_point: true }

  let(:headers) { { Authorization: "Bearer #{Figaro.env.pipefy_token}" } }
  let(:params) { { data: { action: 'card.done', done_by: { id: 101_381, name: 'Foo Bar', username: 'foo', email: 'foo@bar.com', avatar_url: 'gravatar' }, card: { id: 4_648_391, pipe_id: '5fc4VmAE' } } }.with_indifferent_access }

  let(:card_response) { { data: { card: { id: '4648391', title: 'teste 2', assignees: [], comments: [], comments_count: 0, current_phase: { name: 'Concluído' }, done: true, due_date: nil, fields: [{ name: 'O quê?', value: 'teste 2' }, { name: 'Type', value: 'Bug' }], labels: [{ name: 'BUG' }], phases_history: [{ phase: { id: '2481594', name: 'Start form', done: false, fields: [{ label: 'O quê?' }, { label: 'Type' }] }, lastTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-16T22:44:57-02:00' }, { phase: { id: '2481595', name: 'Caixa de entrada', done: false, fields: [{ label: 'Commitment Point' }] }, lastTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-17T23:01:46-02:00' }, { phase: { id: '2481596', name: 'Fazendo', done: false, fields: [{ label: 'Commitment Point' }] }, lastTimeIn: '2018-01-16T23:01:46-02:00', lastTimeOut: '2018-02-11T17:43:22-02:00' }, { phase: { id: '2481597', name: 'Concluído', done: true, fields: [] }, lastTimeIn: '2018-02-09T01:01:41-02:00', lastTimeOut: nil }], pipe: { id: '356528' }, url: 'http://app.pipefy.com/pipes/356528#cards/4648391' } } }.with_indifferent_access }
  let(:other_card_response) { { data: { card: { id: '4648389', title: 'teste 2', assignees: [], comments: [], comments_count: 0, current_phase: { name: 'Concluído' }, done: true, due_date: nil, fields: [{ name: 'O quê?', value: 'teste 2' }, { name: 'Type', value: 'Nova Funcionalidade' }], labels: [{ name: 'BUG' }], phases_history: [{ phase: { id: '2481595', name: 'Caixa de entrada', done: false, fields: [{ label: 'Commitment Point' }] }, lastTimeIn: '2018-02-09T01:01:41-02:00', lastTimeOut: '2018-02-11T01:01:41-02:00' }], pipe: { id: '356528' }, url: 'http://app.pipefy.com/pipes/356528#cards/4648389' } } }.with_indifferent_access }
  let(:pipe_response) { { data: { pipe: { phases: [{ id: '2481594' }, { id: '2481595' }, { id: '2481596' }, { id: '2481597' }] } } }.with_indifferent_access }

  let(:phase_response) { { data: { phase: { cards: { pageInfo: { endCursor: 'WzUxNDEwNDdd', hasNextPage: false }, edges: [{ node: { id: '4648391' } }, { node: { id: '4648389' } }] } } } }.with_indifferent_access }

  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      ProcessPipefyPipeJob.perform_later
      expect(ProcessPipefyPipeJob).to have_been_enqueued.on_queue('default')
    end
  end

  context 'having no pipe_config' do
    it 'returns doing nothing' do
      expect_any_instance_of(ProcessPipefyPipeJob).to receive(:read_cards_from_pipe_response).never
      ProcessPipefyPipeJob.perform_now(false)
    end
  end

  context 'having params' do
    before do
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648391/).to_return(status: 200, body: card_response.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648389/).to_return(status: 200, body: other_card_response.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /356528/).to_return(status: 200, body: pipe_response.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481594/).to_return(status: 200, body: phase_response.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481595/).to_return(status: 200, body: phase_response.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481596/).to_return(status: 200, body: phase_response.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481597/).to_return(status: 200, body: phase_response.to_json, headers: {})
    end

    context 'and a pipefy config' do
      let!(:pipefy_config) { Fabricate :pipefy_config, project: project, team: team, pipe_id: '356528' }
      let!(:demand) { Fabricate :demand, project: project, demand_id: '4648391' }
      let!(:other_demand) { Fabricate :demand, project: project, demand_id: '4648389' }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand }
      let!(:other_demand_transition) { Fabricate :demand_transition, demand: other_demand }

      context 'returning success' do
        it 'creates the demand the project_result for the card end_date' do
          expect(PipefyReader.instance).to receive(:update_card!).with(team, demand, card_response).once
          expect(PipefyReader.instance).to receive(:update_card!).with(team, other_demand, other_card_response).once
          ProcessPipefyPipeJob.perform_now(false)
        end
      end

      context 'returning an error' do
        let!(:pipefy_config) { Fabricate :pipefy_config, project: project, team: team, pipe_id: '356528' }

        context 'in a card response' do
          before do
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648391/).to_return(status: 500, body: card_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648389/).to_return(status: 200, body: other_card_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /356528/).to_return(status: 200, body: pipe_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481594/).to_return(status: 200, body: phase_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481595/).to_return(status: 200, body: phase_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481596/).to_return(status: 200, body: phase_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481597/).to_return(status: 200, body: phase_response.to_json, headers: {})
          end
          it 'process nothing for the error response, but process the success ones' do
            expect(PipefyReader.instance).to receive(:update_card!).with(team, demand, card_response).never
            expect(PipefyReader.instance).to receive(:update_card!).with(team, other_demand, other_card_response).once
            ProcessPipefyPipeJob.perform_now(false)
          end
        end

        context 'in the pipe response' do
          before do
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648391/).to_return(status: 200, body: card_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648389/).to_return(status: 200, body: other_card_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /356528/).to_return(status: 500, body: 'there is a problem', headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481594/).to_return(status: 200, body: phase_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481595/).to_return(status: 200, body: phase_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481596/).to_return(status: 200, body: phase_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481597/).to_return(status: 200, body: phase_response.to_json, headers: {})
          end

          it 'process nothing for the error response, but process the success ones' do
            expect(PipefyReader.instance).to receive(:create_card!).with(team, card_response).never
            expect(PipefyReader.instance).to receive(:create_card!).with(team, other_card_response).never
            ProcessPipefyPipeJob.perform_now(false)
          end
        end
        context 'in the phase response' do
          before do
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648391/).to_return(status: 200, body: card_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648389/).to_return(status: 200, body: other_card_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /356528/).to_return(status: 200, body: pipe_response.to_json, headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481594/).to_return(status: 500, body: 'there is a problem', headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481595/).to_return(status: 500, body: 'there is a problem', headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481596/).to_return(status: 500, body: 'there is a problem', headers: {})
            stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481597/).to_return(status: 500, body: 'there is a problem', headers: {})
          end

          it 'process nothing for the error response, but process the success ones' do
            expect(PipefyReader.instance).to receive(:create_card!).with(team, card_response).never
            expect(PipefyReader.instance).to receive(:create_card!).with(team, other_card_response).never
            ProcessPipefyPipeJob.perform_now(false)
          end
        end
      end
    end

    context 'and no pipe config' do
      context 'when there is no demand and project result' do
        it 'creates the demand the project_result for the card end_date' do
          expect(PipefyReader.instance).to receive(:create_card!).never
          ProcessPipefyPipeJob.perform_now(false)
        end
      end
    end

    context 'with full reading true' do
      let(:with_page_phase_response) { { data: { phase: { cards: { pageInfo: { endCursor: 'WzUxNDEwNDdd', hasNextPage: true }, edges: [{ node: { id: '4648391' } }, { node: { id: '4648389' } }] } } } }.with_indifferent_access }
      let!(:pipefy_config) { Fabricate :pipefy_config, project: project, team: team, pipe_id: '356528' }
      let!(:demand) { Fabricate :demand, project: project, demand_id: '4648391' }
      let!(:other_demand) { Fabricate :demand, project: project, demand_id: '4648389' }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand }
      let!(:other_demand_transition) { Fabricate :demand_transition, demand: other_demand }

      it 'creates the demand the project_result for the card end_date' do
        stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481597/).to_return(status: 200, body: with_page_phase_response.to_json, headers: {})
        stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /WzUxNDEwNDdd/).to_return(status: 200, body: phase_response.to_json, headers: {})
        expect(PipefyReader.instance).to receive(:update_card!).with(team, demand, card_response).once
        expect(PipefyReader.instance).to receive(:update_card!).with(team, other_demand, other_card_response).once
        ProcessPipefyPipeJob.perform_now(true)
      end
    end
  end

  context 'and returning no demand' do
    let!(:pipefy_config) { Fabricate :pipefy_config, project: project, team: team, pipe_id: '356528' }
    let!(:demand) { Fabricate :demand, project: project, demand_id: '4648391' }
    let!(:demand_transition) { Fabricate :demand_transition, demand: demand }

    before do
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648391/).to_return(status: 200, body: { data: { card: nil } }.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /4648389/).to_return(status: 200, body: other_card_response.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /356528/).to_return(status: 200, body: pipe_response.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481594/).to_return(status: 200, body: phase_response.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481595/).to_return(status: 200, body: phase_response.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481596/).to_return(status: 200, body: phase_response.to_json, headers: {})
      stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481597/).to_return(status: 200, body: phase_response.to_json, headers: {})
    end

    it 'process nothing for the error response, but process the success ones' do
      ProcessPipefyPipeJob.perform_now(false)
      expect(Demand.find_by(demand_id: '4648391')).to be_nil
    end
  end
end
