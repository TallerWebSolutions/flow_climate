# frozen_string_literal: true

RSpec.describe PipefyReader, type: :service do
  describe '#process_card' do
    let(:customer) { Fabricate :customer, name: 'bla' }
    let(:other_customer) { Fabricate :customer, name: 'foo' }
    let(:product) { Fabricate :product, customer: customer, name: 'xpto' }
    let(:other_product) { Fabricate :product, customer: customer, name: 'bar' }

    let(:first_project) { Fabricate :project, customer: customer, product: product, name: 'Fase 1', start_date: Time.iso8601('2018-01-04T23:01:46-02:00'), end_date: Time.iso8601('2018-02-25T23:01:46-02:00') }
    let(:second_project) { Fabricate :project, customer: customer, product: product, name: 'Fase 2', start_date: Time.iso8601('2018-02-26T23:01:46-02:00'), end_date: Time.iso8601('2018-04-25T23:01:46-02:00') }
    let(:third_project) { Fabricate :project, customer: other_customer, product: other_product, name: 'Fase 1', start_date: Time.iso8601('2018-02-26T23:01:46-02:00'), end_date: Time.iso8601('2018-04-25T23:01:46-02:00') }

    let(:team) { Fabricate :team }
    let!(:stage) { Fabricate :stage, projects: [first_project, second_project, third_project], integration_id: '2481595', compute_effort: true }
    let!(:end_stage) { Fabricate :stage, projects: [first_project, second_project, third_project], integration_id: '2481597', compute_effort: false, end_point: true }
    let!(:other_end_stage) { Fabricate :stage, integration_id: '2480504', compute_effort: false, end_point: true }

    let(:first_card_response) { { data: { card: { id: '5140999', comments: [], fields: [{ name: 'Descrição da pesquisa', value: 'teste' }, { name: 'Title', value: 'Página dos colunistas' }, { name: 'Type', value: 'bUG' }, { name: 'JiraKey', value: 'PD-46' }, { name: 'Class of Service', value: 'Padrão' }, { name: 'Project', value: 'bLa | XpTO | FASE 1' }], phases_history: [{ phase: { id: '2481595' }, firstTimeIn: '2018-02-22T17:09:58-03:00', lastTimeOut: '2018-02-26T17:09:58-03:00' }, { phase: { id: '2481597' }, firstTimeIn: '2018-02-23T17:09:58-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5140999' } } }.with_indifferent_access }
    let(:second_card_response) { { data: { card: { id: '5141010', comments: [], fields: [{ name: 'Title', value: 'Simplicação dos passos para cadastrar um novo artigo pelo colunista' }, { name: 'Type', value: 'chORE' }, { name: 'JiraKey', value: 'PD-119' }, { name: 'Class of Service', value: 'Expedição' }, { name: 'Project', value: 'bLa | XpTO | FASE 2' }], phases_history: [{ phase: { id: '2481595' }, firstTimeIn: '2018-02-23T17:10:40-03:00', lastTimeOut: '2018-02-27T17:10:40-03:00' }, { phase: { id: '2481597' }, firstTimeIn: '2018-02-23T17:10:40-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141010' } } }.with_indifferent_access }
    let(:third_card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'Nova Funcionalidade' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'Data Fixa' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
    let(:pipe_response) { { data: { pipe: { phases: [{ cards: { edges: [{ node: { id: '4648389', title: 'ateste' } }] } }, { cards: { edges: [] } }, { cards: { edges: [{ node: { id: '4648391', title: 'teste 2' } }] } }] } } }.with_indifferent_access }

    context 'having no matching project' do
      let(:first_project) { Fabricate :project, customer: customer, product: product, name: 'Fase 5', start_date: Time.iso8601('2018-01-11T23:01:46-02:00'), end_date: Time.iso8601('2018-02-25T23:01:46-02:00') }
      it 'processes the card creating or updating the models' do
        PipefyReader.instance.process_card(team, first_card_response)

        expect(Demand.count).to eq 0
      end
    end
    context 'having pipefy_config' do
      let!(:pipefy_config) { Fabricate :pipefy_config, project: first_project, team: team, pipe_id: '356528' }

      context 'when the demand exists' do
        context 'and the project result is in another date' do
          let!(:demand) { Fabricate :demand, project: first_project, project_result: nil, demand_id: '5140999' }
          let!(:project_result) { Fabricate :project_result, project: first_project, demands: [demand], result_date: '2018-01-10T01:01:41-02:00' }

          it 'processes the card updating the demand' do
            PipefyReader.instance.process_card(team, first_card_response)

            expect(Demand.count).to eq 1
            expect(Demand.last.class_of_service).to eq 'standard'
            expect(Demand.last.demand_type).to eq 'bug'
            expect(Demand.last.demand_id).to eq '5140999'

            expect(ProjectResult.count).to eq 2

            updated_result = ProjectResult.first
            expect(updated_result.result_date).to eq Date.new(2018, 1, 10)
            expect(updated_result.known_scope).to eq 0
            expect(updated_result.qty_hours_downstream).to eq 0
            expect(updated_result.qty_hours_upstream).to eq 0
            expect(updated_result.qty_hours_bug).to eq 0

            created_result = ProjectResult.second
            expect(created_result.result_date).to eq Date.new(2018, 2, 23)
            expect(created_result.known_scope).to eq 1
            expect(created_result.qty_hours_downstream).to eq 16
            expect(created_result.qty_hours_upstream).to eq 0
            expect(created_result.qty_hours_bug).to eq 16
          end
        end
        context 'and the project result is in the same date' do
          let!(:demand) { Fabricate :demand, project: first_project, project_result: nil, demand_id: '5140999' }
          let!(:project_result) { Fabricate :project_result, project: first_project, demands: [demand], result_date: Date.new(2018, 2, 23), known_scope: 5 }

          it 'processes the card updating the demand and project result' do
            PipefyReader.instance.process_card(team, first_card_response)
            expect(Demand.count).to eq 1
            expect(ProjectResult.count).to eq 1
          end
        end
      end

      context 'when the demand does not exist' do
        context 'when it is bug' do
          it 'processes the card creating the demand and project result' do
            PipefyReader.instance.process_card(team, first_card_response)
            created_demand = Demand.last
            expect(created_demand.bug?).to be true
            expect(created_demand.demand_id).to eq '5140999'
            expect(created_demand.effort.to_f).to eq 16.0
            expect(created_demand.class_of_service).to eq 'standard'
            expect(created_demand.url).to eq 'http://app.pipefy.com/pipes/356355#cards/5140999'
          end
        end

        context 'when it is feature' do
          it 'processes the card creating the demand' do
            PipefyReader.instance.process_card(team, second_card_response)
            created_demand = Demand.last
            expect(created_demand.chore?).to be true
            expect(created_demand.demand_id).to eq '5141010'
            expect(created_demand.effort.to_f).to eq 16.0
            expect(created_demand.class_of_service).to eq 'expedite'
            expect(created_demand.url).to eq 'http://app.pipefy.com/pipes/356355#cards/5141010'
          end
        end

        context 'when it is chore' do
          it 'processes the card creating the demand' do
            PipefyReader.instance.process_card(team, third_card_response)
            created_demand = Demand.last
            expect(created_demand.feature?).to be true
            expect(created_demand.demand_id).to eq '5141022'
            expect(created_demand.effort.to_f).to eq 0
            expect(created_demand.class_of_service).to eq 'fixed_date'
            expect(created_demand.url).to eq 'http://app.pipefy.com/pipes/356355#cards/5141022'
          end
        end

        context 'when it is class of service intangible' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'Nova Funcionalidade' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'Intangível' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          it 'processes the card creating the demand' do
            PipefyReader.instance.process_card(team, card_response)
            created_demand = Demand.last
            expect(created_demand.feature?).to be true
            expect(created_demand.demand_id).to eq '5141022'
            expect(created_demand.effort.to_f).to eq 0
            expect(created_demand.class_of_service).to eq 'intangible'
            expect(created_demand.url).to eq 'http://app.pipefy.com/pipes/356355#cards/5141022'
          end
        end
      end
    end
  end
end
