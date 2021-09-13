# frozen_string_literal: true

RSpec.describe Api::V1::TeamsController, type: :controller do
  describe 'GET #average_demand_cost' do
    let(:company) { Fabricate :company }
    let!(:headers) { { HTTP_API_TOKEN: company.api_token } }

    context 'authenticated' do
      context 'with valid parameters' do
        let!(:team) { Fabricate :team, company: company }

        it 'calls the service to build the response' do
          request.headers.merge! headers
          expect(TeamService.instance).to receive(:average_demand_cost_stats_info_hash).with(team)
          get :average_demand_cost, params: { id: team.id }
        end
      end
    end

    context 'with invalid team' do
      it 'never calls the service to build the response and returns unauthorized' do
        request.headers.merge! headers
        expect(TeamService.instance).not_to receive(:average_demand_cost_stats_info_hash)
        get :average_demand_cost, params: { id: 'foo' }

        expect(response).to have_http_status :not_found
      end
    end

    context 'unauthenticated' do
      it 'never calls the service to build the response and returns unauthorized' do
        expect(TeamService.instance).not_to receive(:average_demand_cost_stats_info_hash)
        get :average_demand_cost, params: { id: 'foo' }

        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #items_in_wip' do
    let(:company) { Fabricate :company }
    let!(:headers) { { HTTP_API_TOKEN: company.api_token } }

    let!(:team) { Fabricate :team, company: company }

    let!(:demand) { Fabricate :demand, team: team, commitment_date: Time.zone.now, end_date: nil }

    context 'authenticated' do
      context 'with valid parameters' do
        let!(:team) { Fabricate :team, company: company }

        it 'calls the service to build the response' do
          request.headers.merge! headers
          get :items_in_wip, params: { id: team.id }

          expect(response).to have_http_status :ok
          expect(JSON.parse(response.body)['data'][0]['id']).to eq demand.id
          expect(JSON.parse(response.body)['data'][0]['external_id']).to eq demand.external_id
        end
      end
    end

    context 'with invalid team' do
      it 'never calls the service to build the response and returns unauthorized' do
        request.headers.merge! headers
        get :items_in_wip, params: { id: 'foo' }

        expect(response).to have_http_status :not_found
      end
    end

    context 'unauthenticated' do
      it 'never calls the service to build the response and returns unauthorized' do
        get :items_in_wip, params: { id: 'foo' }

        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #items_delivered_last_week' do
    before { travel_to Time.zone.local(2019, 8, 12, 10, 0, 0) }

    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let!(:team) { Fabricate :team, company: company }
    let(:project) { Fabricate :project, company: company, team: team }

    let!(:headers) { { HTTP_API_TOKEN: company.api_token } }

    context 'authenticated' do
      context 'with valid parameters' do
        context 'with data' do
          let!(:first_demand) { Fabricate :demand, team: team, project: project, demand_type: :bug, end_date: 1.week.ago, effort_downstream: 100, effort_upstream: 10 }
          let!(:second_demand) { Fabricate :demand, team: team, project: project, demand_type: :bug, end_date: 3.weeks.ago }
          let!(:third_demand) { Fabricate :demand, team: team, project: project, demand_type: :bug, end_date: 2.days.ago }
          let!(:fourth_demand) { Fabricate :demand, team: team, project: project, demand_type: :feature, end_date: 3.weeks.ago }
          let!(:fifth_demand) { Fabricate :demand, team: team, project: project, demand_type: :chore, end_date: Time.zone.now }
          let!(:sixth_demand) { Fabricate :demand, team: team, project: project, demand_type: :feature, end_date: 2.weeks.ago }
          let!(:seventh_demand) { Fabricate :demand, team: team, project: project, demand_type: :feature, end_date: Time.zone.now }
          let!(:eighth_demand) { Fabricate :demand, team: team, project: project, demand_type: :chore, commitment_date: Time.zone.now, end_date: nil, effort_downstream: 200, effort_upstream: 300 }
          let!(:team_member) { Fabricate :team_member, monthly_payment: 1200, end_date: nil }

          it 'calls the service to build the response' do
            membership = Fabricate :membership, team: team, team_member: team_member, hours_per_month: 100, start_date: 1.month.ago, end_date: nil

            Fabricate :item_assignment, demand: first_demand, membership: membership, start_time: 1.month.ago, finish_time: nil
            Fabricate :item_assignment, demand: second_demand, membership: membership, start_time: 1.month.ago, finish_time: nil
            Fabricate :item_assignment, demand: third_demand, membership: membership, start_time: 7.weeks.ago, finish_time: nil

            request.headers.merge! headers
            get :items_delivered_last_week, params: { id: team.id }

            expect(response).to have_http_status :ok
            expect(JSON.parse(response.body)['data'].map { |demand| demand['id'] }).to match_array [first_demand.id, third_demand.id]
            expect(JSON.parse(response.body)['data'].map { |demand| demand['external_id'] }).to match_array [first_demand.external_id, third_demand.external_id]
          end
        end

        context 'with no data' do
          it 'calls the service to build the response' do
            request.headers.merge! headers
            get :items_delivered_last_week, params: { id: team.id }

            expect(response).to have_http_status :ok
            expect(JSON.parse(response.body)['data'].count).to eq 0
          end
        end
      end
    end

    context 'with invalid team' do
      it 'never calls the service to build the response and returns unauthorized' do
        request.headers.merge! headers
        get :items_delivered_last_week, params: { id: 'foo' }

        expect(response).to have_http_status :not_found
      end
    end

    context 'unauthenticated' do
      it 'never calls the service to build the response and returns unauthorized' do
        get :items_delivered_last_week, params: { id: 'foo' }

        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
