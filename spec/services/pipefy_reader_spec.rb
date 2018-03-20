# frozen_string_literal: true

RSpec.describe PipefyReader, type: :service do
  let(:customer) { Fabricate :customer, name: 'bla' }
  let(:other_customer) { Fabricate :customer, name: 'foo' }
  let(:product) { Fabricate :product, customer: customer, name: 'xpto' }
  let(:other_product) { Fabricate :product, customer: customer, name: 'bar' }

  let(:first_project) { Fabricate :project, customer: customer, product: product, name: 'Fase 1', start_date: Date.new(2018, 1, 4), end_date: Date.new(2018, 4, 4) }
  let(:second_project) { Fabricate :project, customer: customer, product: product, name: 'Fase 2', start_date: Date.new(2018, 2, 26), end_date: Date.new(2018, 4, 25) }
  let(:third_project) { Fabricate :project, customer: other_customer, product: other_product, name: 'Fase 1', start_date: Date.new(2018, 2, 26), end_date: Date.new(2018, 4, 25) }

  let(:team) { Fabricate :team }
  let!(:stage) { Fabricate :stage, projects: [first_project, second_project, third_project], integration_id: '2481595', compute_effort: true }
  let!(:end_stage) { Fabricate :stage, projects: [first_project, second_project, third_project], integration_id: '2481597', compute_effort: false, end_point: true }
  let!(:other_end_stage) { Fabricate :stage, integration_id: '2480504', compute_effort: false, end_point: true }

  let(:first_card_response) { { data: { card: { id: '5140999', assignees: [{ id: '101381', username: 'xpto' }, { id: '101381', username: 'xpto' }, { id: '101382', username: 'bla' }, { id: '101321', username: 'mambo' }], comments: [{ created_at: '2018-02-22T18:39:46-03:00', author: { username: 'sbbrubles' }, text: '[BLOCKED]: xpto of bla having foo.' }], fields: [{ name: 'Descrição da pesquisa', value: 'teste' }, { name: 'Title', value: 'Página dos colunistas' }, { name: 'Type', value: 'bUG' }, { name: 'JiraKey', value: 'PD-46' }, { name: 'Class of Service', value: 'Padrão' }, { name: 'Project', value: 'bLa | XpTO | FASE 1' }], phases_history: [{ phase: { id: '2481595' }, firstTimeIn: '2018-02-22T17:09:58-03:00', lastTimeOut: '2018-02-26T17:09:58-03:00' }, { phase: { id: '2481597' }, firstTimeIn: '2018-02-23T17:09:58-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5140999' } } }.with_indifferent_access }
  let(:second_card_response) { { data: { card: { id: '5141010', assignees: [], comments: [{ created_at: '2018-02-24T18:39:46-03:00', author: { username: 'sbbrubles' }, text: '[BLOCKED][1]: xpto of bla having foo in the block 1.' }, { created_at: '2018-02-25T18:39:46-03:00', author: { username: 'sbbrubles' }, text: '[BLOCKED][2]: xpto of bla having foo.' }, { created_at: '2018-02-26T14:39:46-03:00', author: { username: 'sbbrubles' }, text: '[UNBLOCKED][2]: there is no more xpto of bla having foo.' }], fields: [{ name: 'Title', value: 'Simplicação dos passos para cadastrar um novo artigo pelo colunista' }, { name: 'Type', value: 'chORE' }, { name: 'JiraKey', value: 'PD-119' }, { name: 'Class of Service', value: 'Expedição' }, { name: 'Project', value: 'bLa | XpTO | FASE 2' }], phases_history: [{ phase: { id: '2481595' }, firstTimeIn: '2018-02-23T17:10:40-03:00', lastTimeOut: '2018-02-27T17:10:40-03:00' }, { phase: { id: '2481597' }, firstTimeIn: '2018-02-27T17:10:40-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141010' } } }.with_indifferent_access }
  let(:third_card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'Nova Funcionalidade' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'Data Fixa' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
  let(:pipe_response) { { data: { pipe: { phases: [{ cards: { edges: [{ node: { id: '4648389', title: 'ateste' } }] } }, { cards: { edges: [] } }, { cards: { edges: [{ node: { id: '4648391', title: 'teste 2' } }] } }] } } }.with_indifferent_access }

  describe '#create_card!' do
    context 'having no matching project' do
      let(:first_project) { Fabricate :project, customer: customer, product: product, name: 'Fase 5', start_date: Time.zone.iso8601('2018-01-11T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-25T23:01:46-02:00') }
      it 'processes the card creating or updating the models' do
        PipefyReader.instance.create_card!(team, first_card_response)

        expect(Demand.count).to eq 0
      end
    end
    context 'having pipefy_config' do
      let!(:first_pipefy_config) { Fabricate :pipefy_config, project: first_project, team: team, pipe_id: '356528', active: true }
      let!(:second_pipefy_config) { Fabricate :pipefy_config, project: second_project, team: team, pipe_id: '356528', active: true }
      let!(:third_pipefy_config) { Fabricate :pipefy_config, project: third_project, team: team, pipe_id: '356528', active: true }

      let!(:first_pipefy_team_config) { Fabricate :pipefy_team_config, team: team, integration_id: '101381', username: 'xpto', member_type: :developer }
      let!(:second_pipefy_team_config) { Fabricate :pipefy_team_config, team: team, integration_id: '101382', username: 'bla', member_type: :analyst }

      context 'when the demand exists' do
        context 'and the project result is in another date' do
          let!(:first_demand) { Fabricate :demand, project: first_project, project_result: nil, effort: 50 }
          let!(:second_demand) { Fabricate :demand, project: first_project, project_result: nil, demand_id: '5140999', effort: 30, created_date: Time.zone.parse('2018-02-17') }
          let!(:first_transition) { Fabricate :demand_transition, stage: end_stage, demand: first_demand, last_time_in: '2018-02-14T01:01:41-02:00', last_time_out: '2018-02-16T01:01:41-02:00' }
          let!(:second_transition) { Fabricate :demand_transition, stage: end_stage, demand: second_demand, last_time_in: '2018-02-16T01:01:41-02:00', last_time_out: '2018-02-16T01:42:41-02:00' }
          let!(:project_result) { Fabricate :project_result, project: first_project, demands: [first_demand, second_demand], result_date: Date.new(2018, 2, 15), demands_count: 2 }

          context 'when the card has only one block not unblocked' do
            it 'does not change the demand' do
              PipefyReader.instance.create_card!(team, first_card_response)

              expect(PipefyTeamConfig.count).to eq 3
              expect(PipefyTeamConfig.first.integration_id).to eq '101381'
              expect(PipefyTeamConfig.first.username).to eq 'xpto'

              expect(PipefyTeamConfig.second.integration_id).to eq '101382'
              expect(PipefyTeamConfig.second.username).to eq 'bla'

              expect(PipefyTeamConfig.third.integration_id).to eq '101321'
              expect(PipefyTeamConfig.third.username).to eq 'mambo'

              expect(Demand.count).to eq 2
              expect(Demand.first.project_result).to eq project_result

              updated_demand = Demand.find_by(demand_id: '5140999')
              expect(updated_demand.class_of_service).to eq 'standard'
              expect(updated_demand.demand_type).to eq 'feature'
              expect(updated_demand.demand_id).to eq '5140999'
              expect(updated_demand.assignees_count).to eq 1
              expect(updated_demand.effort.to_f).to eq 30

              expect(DemandBlock.count).to eq 0
              expect(ProjectResult.count).to eq 1
            end
          end
        end
        context 'and the project result is in the same date' do
          let!(:demand) { Fabricate :demand, project: first_project, project_result: nil, demand_id: '5140999' }
          let!(:project_result) { Fabricate :project_result, project: first_project, demands: [demand], result_date: Date.new(2018, 2, 23), known_scope: 5 }

          it 'processes the card updating the demand and project result' do
            PipefyReader.instance.create_card!(team, first_card_response)
            expect(Demand.count).to eq 1
            expect(ProjectResult.count).to eq 1
          end
        end
      end

      context 'when the demand does not exist' do
        it 'creates the demand' do
          PipefyReader.instance.create_card!(team, first_card_response)

          expect(Demand.count).to eq 1

          created_demand = Demand.find_by(demand_id: '5140999')
          expect(created_demand.class_of_service).to eq 'standard'
          expect(created_demand.demand_type).to eq 'bug'
          expect(created_demand.demand_id).to eq '5140999'
          expect(created_demand.assignees_count).to eq 2
          expect(created_demand.effort.to_f).to eq 0.0

          expect(DemandBlock.count).to eq 0
          expect(ProjectResult.count).to eq 0
        end
      end

      context 'when the project has a previous manual added project_result' do
        let!(:first_project_result) { Fabricate :project_result, project: first_project, result_date: Date.new(2018, 2, 10), known_scope: 100 }
        let!(:second_project_result) { Fabricate :project_result, project: first_project, result_date: Date.new(2018, 2, 9), known_scope: 90 }
        it 'computes the last manual scope' do
          PipefyReader.instance.create_card!(team, first_card_response)
          expect(ProjectResult.count).to eq 2
          expect(ProjectResult.last.known_scope).to eq 90
        end
      end

      context 'when the demand does not exist' do
        context 'when it is unknown to the system' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'sbbrubles' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'Intangível' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          it 'processes the card creating the demand as feature and project result' do
            PipefyReader.instance.create_card!(team, card_response)
            created_demand = Demand.last
            expect(created_demand.feature?).to be true
            expect(created_demand.demand_id).to eq '5141022'
            expect(created_demand.assignees_count).to eq 1
            expect(created_demand.effort.to_f).to eq 0.0
            expect(created_demand.class_of_service).to eq 'intangible'
            expect(created_demand.url).to eq 'http://app.pipefy.com/pipes/356355#cards/5141022'
          end
        end

        context 'when it is bug' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'buG' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'Intangível' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          before { PipefyReader.instance.create_card!(team, card_response) }
          it { expect(Demand.last.bug?).to be true }
        end

        context 'when it is feature' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'feaTURE' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'Intangível' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          before { PipefyReader.instance.create_card!(team, card_response) }
          it { expect(Demand.last.feature?).to be true }
        end

        context 'when it is chore' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'chORE' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'Intangível' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          before { PipefyReader.instance.create_card!(team, card_response) }
          it { expect(Demand.last.chore?).to be true }
        end

        context 'when it is ux_improvement' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'MelhOrIa uX' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'Intangível' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          before { PipefyReader.instance.create_card!(team, card_response) }
          it { expect(Demand.last.ux_improvement?).to be true }
        end

        context 'when it is ux_improvement' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'MelhOrIa perforMANcE' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'Intangível' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          before { PipefyReader.instance.create_card!(team, card_response) }
          it { expect(Demand.last.performance_improvement?).to be true }
        end

        context 'when its class of service is unknown' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'MelhOrIa perforMANcE' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'sbbrubles' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          before { PipefyReader.instance.create_card!(team, card_response) }
          it { expect(Demand.last.standard?).to be true }
        end

        context 'when its class of service is standard' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'MelhOrIa perforMANcE' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'stanDARD' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          before { PipefyReader.instance.create_card!(team, card_response) }
          it { expect(Demand.last.standard?).to be true }
        end

        context 'when its class of service is expedite' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'MelhOrIa perforMANcE' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'exPEDição' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          before { PipefyReader.instance.create_card!(team, card_response) }
          it { expect(Demand.last.expedite?).to be true }
        end

        context 'when its class of service is intangible' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'MelhOrIa perforMANcE' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'inTANgível' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          before { PipefyReader.instance.create_card!(team, card_response) }
          it { expect(Demand.last.intangible?).to be true }
        end

        context 'when its class of service is fixed_date' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'MelhOrIa perforMANcE' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'data FIXA' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          before { PipefyReader.instance.create_card!(team, card_response) }
          it { expect(Demand.last.fixed_date?).to be true }
        end

        context 'when it is class of service intangible' do
          let(:card_response) { { data: { card: { id: '5141022', comments: [], fields: [{ name: 'Title', value: 'Agendamento de artigo do colunista' }, { name: 'Type', value: 'Nova Funcionalidade' }, { name: 'JiraKey', value: 'PD-124' }, { name: 'Class of Service', value: 'Intangível' }, { name: 'Project', value: 'Foo | BaR | FASE 1' }], phases_history: [{ phase: { id: '2480502' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: '2018-02-23T17:11:23-03:00' }, { phase: { id: '2480504' }, firstTimeIn: '2018-02-23T17:11:23-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141022' } } }.with_indifferent_access }
          it 'processes the card creating the demand' do
            PipefyReader.instance.create_card!(team, card_response)
            created_demand = Demand.last
            expect(created_demand.feature?).to be true
            expect(created_demand.demand_id).to eq '5141022'
            expect(created_demand.assignees_count).to eq 1
            expect(created_demand.effort.to_f).to eq 0
            expect(created_demand.class_of_service).to eq 'intangible'
            expect(created_demand.url).to eq 'http://app.pipefy.com/pipes/356355#cards/5141022'
          end
        end
      end
    end
  end

  describe '#update_card!' do
    context 'having pipefy_config' do
      let!(:first_pipefy_config) { Fabricate :pipefy_config, project: first_project, team: team, pipe_id: '356528', active: true }
      let!(:second_pipefy_config) { Fabricate :pipefy_config, project: second_project, team: team, pipe_id: '356528', active: true }
      let!(:third_pipefy_config) { Fabricate :pipefy_config, project: third_project, team: team, pipe_id: '356528', active: true }

      let!(:first_pipefy_team_config) { Fabricate :pipefy_team_config, team: team, integration_id: '101381', username: 'xpto', member_type: :developer }
      let!(:second_pipefy_team_config) { Fabricate :pipefy_team_config, team: team, integration_id: '101382', username: 'bla', member_type: :analyst }

      let!(:first_demand) { Fabricate :demand, project: first_project, project_result: nil, effort: 50 }
      let!(:second_demand) { Fabricate :demand, project: first_project, project_result: nil, demand_id: '5141010', effort: 30, created_date: Time.zone.parse('2018-02-17') }
      let!(:first_transition) { Fabricate :demand_transition, stage: end_stage, demand: first_demand, last_time_in: '2018-02-14T01:01:41-02:00', last_time_out: '2018-02-16T01:01:41-02:00' }
      let!(:second_transition) { Fabricate :demand_transition, stage: end_stage, demand: second_demand, last_time_in: '2018-02-16T01:01:41-02:00', last_time_out: '2018-02-16T01:42:41-02:00' }
      let!(:project_result) { Fabricate :project_result, project: first_project, demands: [first_demand, second_demand], result_date: Date.new(2018, 2, 15), demands_count: 2 }

      context 'blocked but not unblocked' do
        it 'creates the demand and the project result' do
          PipefyReader.instance.update_card!(team, second_demand, second_card_response)

          expect(Demand.count).to eq 2

          updated_demand = Demand.find_by(demand_id: '5141010')
          expect(updated_demand.class_of_service).to eq 'expedite'
          expect(updated_demand.demand_type).to eq 'chore'
          expect(updated_demand.assignees_count).to eq 1
          expect(updated_demand.effort.to_f).to eq 6.0
          expect(updated_demand.project).to eq second_project

          expect(DemandBlock.count).to eq 2
          first_block = Demand.last.demand_blocks.first
          expect(first_block.demand_block_id).to eq 1
          expect(first_block.block_reason).to eq '[BLOCKED][1]: xpto of bla having foo in the block 1.'
          expect(first_block.block_time).to eq Time.zone.iso8601('2018-02-24T18:39:46-03:00')
          expect(first_block.blocker_username).to eq 'sbbrubles'
          expect(first_block.unblocker_username).to be_nil
          expect(first_block.unblock_time).to be_nil
          expect(first_block.unblock_reason).to be_nil

          second_block = Demand.last.demand_blocks.second
          expect(second_block.demand_block_id).to eq 2
          expect(second_block.block_reason).to eq '[BLOCKED][2]: xpto of bla having foo.'
          expect(second_block.block_time).to eq Time.zone.iso8601('2018-02-25T18:39:46-03:00')
          expect(second_block.blocker_username).to eq 'sbbrubles'
          expect(second_block.unblocker_username).to eq 'sbbrubles'
          expect(second_block.unblock_time).to eq Time.zone.iso8601('2018-02-26T14:39:46-03:00')
          expect(second_block.unblock_reason).to eq '[UNBLOCKED][2]: there is no more xpto of bla having foo.'

          expect(ProjectResult.count).to eq 2

          created_result = updated_demand.project_result
          expect(created_result.project).to eq second_project
          expect(created_result.result_date).to eq Date.new(2018, 2, 27)
          expect(created_result.known_scope).to eq 1
          expect(created_result.qty_hours_downstream).to eq 6
          expect(created_result.qty_hours_upstream).to eq 0
          expect(created_result.qty_hours_bug).to eq 0
          expect(created_result.demands).to eq [updated_demand]
          expect(created_result.demands_count).to eq 1

          expect(first_project.reload.demands).to eq [first_demand]
          expect(first_project.reload.project_results).to eq [project_result]
          expect(second_project.reload.project_results).to eq [created_result]

          expect(project_result.reload.demands).to eq [first_demand]
        end
      end

      context 'when the card has multiple blocks, some not unblocked' do
        let!(:demand_block) { Fabricate :demand_block, demand: first_demand, demand_block_id: 1, block_time: Time.zone.iso8601('2018-02-18T18:39:46-03:00') }
        let(:card_response) { { data: { card: { id: '5140999', assignees: [], comments: [{ created_at: '2018-02-18T18:39:46-03:00', author: { username: 'sbbrubles' }, text: '[BLOCKED][1]: xpto of bla having foo in the block 1.' }, { created_at: '2018-02-18T19:55:46-03:00', author: { username: 'sbbrubles' }, text: '[BLOCKED][2]: xpto of bla having foo.' }, { created_at: '2018-02-24T22:10:46-03:00', author: { username: 'johndoe' }, text: '[UNBLOCKED][2]: there is no more xpto of bla having foo.' }, { created_at: '2018-02-24T22:10:46-03:00', author: { username: 'johndoe' }, text: '[UNBLOCKED][5]: this unblock was not blocked.' }], fields: [{ name: 'Title', value: 'Simplicação dos passos para cadastrar um novo artigo pelo colunista' }, { name: 'Type', value: 'chORE' }, { name: 'JiraKey', value: 'PD-119' }, { name: 'Class of Service', value: 'Expedição' }, { name: 'Project', value: 'bLa | XpTO | FASE 2' }], phases_history: [{ phase: { id: '2481595' }, firstTimeIn: '2018-02-23T17:10:40-03:00', lastTimeOut: '2018-02-27T17:10:40-03:00' }, { phase: { id: '2481597' }, firstTimeIn: '2018-02-23T17:10:40-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5141010' } } }.with_indifferent_access }
        it 'processes the card creating and updating the blocks' do
          PipefyReader.instance.update_card!(team, first_demand, card_response)
          expect(DemandBlock.count).to eq 2
          first_block = DemandBlock.where(demand: first_demand, demand_block_id: '1').first
          expect(first_block.block_reason).to eq '[BLOCKED][1]: xpto of bla having foo in the block 1.'
          expect(first_block.block_time).to eq Time.zone.iso8601('2018-02-18T18:39:46-03:00')
          expect(first_block.blocker_username).to eq 'sbbrubles'

          second_block = DemandBlock.where(demand: first_demand, demand_block_id: '2').first

          expect(second_block.block_reason).to eq '[BLOCKED][2]: xpto of bla having foo.'
          expect(second_block.block_time).to eq Time.zone.iso8601('2018-02-18T19:55:46-03:00')
          expect(second_block.blocker_username).to eq 'sbbrubles'

          expect(second_block.unblocker_username).to eq 'johndoe'
          expect(second_block.unblock_time).to eq Time.zone.iso8601('2018-02-24T22:10:46-03:00')
          expect(second_block.unblock_reason).to eq '[UNBLOCKED][2]: there is no more xpto of bla having foo.'
          expect(second_block.block_duration).to eq 30
        end
      end
    end

    context 'when the project has a previous manual added project_result' do
      let!(:first_project_result) { Fabricate :project_result, project: first_project, result_date: Date.new(2018, 2, 10), known_scope: 100 }
      let!(:second_project_result) { Fabricate :project_result, project: first_project, result_date: Date.new(2018, 2, 9), known_scope: 90 }
      let!(:first_demand) { Fabricate :demand, project: first_project, project_result: nil, effort: 50 }

      it 'computes the last manual scope' do
        PipefyReader.instance.update_card!(team, first_demand, first_card_response)
        expect(ProjectResult.count).to eq 3
        expect(ProjectResult.last.known_scope).to eq 101
      end
    end

    context 'with invalid' do
      context 'project_result' do
        let(:first_project) { Fabricate :project, customer: customer, product: product, name: 'Fase 1', start_date: Date.new(2018, 1, 7), end_date: Date.new(2018, 1, 25) }
        let!(:stage) { Fabricate :stage, projects: [first_project], integration_id: '2481595', compute_effort: true }
        let!(:end_stage) { Fabricate :stage, projects: [first_project], integration_id: '2481597', compute_effort: false, end_point: true }
        let!(:other_end_stage) { Fabricate :stage, integration_id: '2480504', compute_effort: false, end_point: true }
        let(:first_card_response) { { data: { card: { id: '5140999', assignees: [{ id: '101381', username: 'xpto' }, { id: '101381', username: 'xpto' }, { id: '101382', username: 'bla' }, { id: '101321', username: 'mambo' }], comments: [{ created_at: '2018-03-01T18:39:46-03:00', author: { username: 'sbbrubles' }, text: '[BLOCKED]: xpto of bla having foo.' }], fields: [{ name: 'Descrição da pesquisa', value: 'teste' }, { name: 'Title', value: 'Página dos colunistas' }, { name: 'Type', value: 'bUG' }, { name: 'JiraKey', value: 'PD-46' }, { name: 'Class of Service', value: 'Padrão' }, { name: 'Project', value: 'bLa | XpTO | FASE 1' }], phases_history: [{ phase: { id: '2481595' }, firstTimeIn: '2018-02-22T17:09:58-03:00', lastTimeOut: '2018-02-26T17:09:58-03:00' }, { phase: { id: '2481597' }, firstTimeIn: '2018-02-23T17:09:58-03:00', lastTimeOut: nil }], pipe: { id: '356355' }, url: 'http://app.pipefy.com/pipes/356355#cards/5140999' } } }.with_indifferent_access }
        let!(:first_pipefy_config) { Fabricate :pipefy_config, project: first_project, team: team, pipe_id: '356528', active: true }
        let!(:first_demand) { Fabricate :demand, project: first_project, project_result: nil, effort: 50 }

        it 'adds integration error' do
          PipefyReader.instance.update_card!(team, first_demand, first_card_response)

          expect(IntegrationError.first.integration_type).to eq 'pipefy'
          expect(IntegrationError.first.project).to eq first_project
          expect(IntegrationError.first.integration_error_text).to eq '[Data A data do resultado deve ser menor ou igual a data final do projeto.][result_date: [2018-02-23]'
        end
      end
    end
  end
end
