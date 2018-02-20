# frozen_string_literal: true

RSpec.describe PipefyData, type: :data_object do
  describe '.initialize' do
    context 'having data' do
      context 'demand type bug' do
        let(:card_response) { { data: { card: { id: '4648391', title: 'teste 2', assignees: [], comments: [], comments_count: 0, current_phase: { name: 'Concluído' }, done: true, due_date: nil, fields: [{ name: 'O quê?', value: 'teste 2' }, { name: 'Type', value: 'Bug' }], labels: [{ name: 'BUG' }], phases_history: [{ phase: { id: '2481594', name: 'Start form', done: false, fields: [{ label: 'O quê?' }, { label: 'Type' }] }, firstTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-16T22:44:57-02:00' }, { phase: { id: '2481595', name: 'Caixa de entrada', done: false, fields: [{ label: 'Commitment Point' }] }, firstTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-16T23:01:46-02:00' }, { phase: { id: '2481596', name: 'Fazendo', done: false, fields: [{ label: 'Commitment Point' }] }, firstTimeIn: '2018-01-16T23:01:46-02:00', lastTimeOut: '2018-02-10T01:06:05-02:00' }, { phase: { id: '2481597', name: 'Concluído', done: true, fields: [] }, firstTimeIn: '2018-02-09T01:01:41-02:00', lastTimeOut: nil }], pipe: { id: '356528' }, url: 'http://app.pipefy.com/pipes/356528#cards/4648391' } } }.with_indifferent_access }
        subject(:pipefy_data) { PipefyData.new(card_response) }

        it 'defines all the fields in the data model' do
          expect(pipefy_data.demand_id).to eq '4648391'
          expect(pipefy_data.pipe_id).to eq '356528'
          expect(pipefy_data.demand_type).to eq :bug
          expect(pipefy_data.created_date).to eq Time.iso8601('2018-01-16T22:44:57-02:00')
          expect(pipefy_data.commitment_date).to eq Time.iso8601('2018-01-16T23:01:46-02:00')
          expect(pipefy_data.end_date).to eq Time.iso8601('2018-02-09T01:01:41-02:00')
        end
      end

      context 'demand type feature' do
        let(:card_response) { { data: { card: { id: '4648391', title: 'teste 2', assignees: [], comments: [], comments_count: 0, current_phase: { name: 'Concluído' }, done: true, due_date: nil, fields: [{ name: 'O quê?', value: 'teste 2' }, { name: 'Type', value: 'nova funcionalidade' }], labels: [{ name: 'BUG' }], phases_history: [{ phase: { id: '2481594', name: 'Start form', done: false, fields: [{ label: 'O quê?' }, { label: 'Type' }] }, firstTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-16T22:44:57-02:00' }, { phase: { id: '2481595', name: 'Caixa de entrada', done: false, fields: [{ label: 'Commitment Point' }] }, firstTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-16T23:01:46-02:00' }, { phase: { id: '2481596', name: 'Fazendo', done: false, fields: [{ label: 'Commitment Point' }] }, firstTimeIn: '2018-01-16T23:01:46-02:00', lastTimeOut: '2018-02-10T01:06:05-02:00' }, { phase: { id: '2481597', name: 'Concluído', done: true, fields: [] }, firstTimeIn: '2018-02-09T01:01:41-02:00', lastTimeOut: nil }], pipe: { id: '356528' }, url: 'http://app.pipefy.com/pipes/356528#cards/4648391' } } }.with_indifferent_access }
        subject(:pipefy_data) { PipefyData.new(card_response) }
        it { expect(pipefy_data.demand_type).to eq :feature }
      end

      context 'demand type chore' do
        let(:card_response) { { data: { card: { id: '4648391', title: 'teste 2', assignees: [], comments: [], comments_count: 0, current_phase: { name: 'Concluído' }, done: true, due_date: nil, fields: [{ name: 'O quê?', value: 'teste 2' }, { name: 'Type', value: 'feature' }], labels: [{ name: 'BUG' }], phases_history: [{ phase: { id: '2481594', name: 'Start form', done: false, fields: [{ label: 'O quê?' }, { label: 'Type' }] }, firstTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-16T22:44:57-02:00' }, { phase: { id: '2481595', name: 'Caixa de entrada', done: false, fields: [{ label: 'Commitment Point' }] }, firstTimeIn: '2018-01-16T22:44:57-02:00', lastTimeOut: '2018-01-16T23:01:46-02:00' }, { phase: { id: '2481596', name: 'Fazendo', done: false, fields: [{ label: 'Commitment Point' }] }, firstTimeIn: '2018-01-16T23:01:46-02:00', lastTimeOut: '2018-02-10T01:06:05-02:00' }, { phase: { id: '2481597', name: 'Concluído', done: true, fields: [] }, firstTimeIn: '2018-02-09T01:01:41-02:00', lastTimeOut: nil }], pipe: { id: '356528' }, url: 'http://app.pipefy.com/pipes/356528#cards/4648391' } } }.with_indifferent_access }
        subject(:pipefy_data) { PipefyData.new(card_response) }
        it { expect(pipefy_data.demand_type).to eq :chore }
      end
    end
    context 'having no data' do
      let(:card_response) { {} }
      subject(:pipefy_data) { PipefyData.new(card_response) }
      it 'defines all the fields in the data model' do
        expect(pipefy_data.demand_id).to eq nil
        expect(pipefy_data.pipe_id).to eq nil
        expect(pipefy_data.demand_type).to eq :feature
        expect(pipefy_data.commitment_date).to eq nil
        expect(pipefy_data.end_date).to eq nil
      end
    end
  end
end
