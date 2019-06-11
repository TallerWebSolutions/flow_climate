# frozen_string_literal: true

RSpec.describe SlackConfigurationsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', team_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', team_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as gold' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }

    after { travel_back }

    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:team) { Fabricate :team, company: company }

    describe 'GET #new' do
      context 'valid parameters' do
        it 'instantiates a new Team and renders the template' do
          get :new, params: { company_id: company, team_id: team }, xhr: true
          expect(response).to render_template 'slack_configurations/new'
          expect(assigns(:slack_configuration)).to be_a_new SlackConfiguration
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo', team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company, team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        it 'creates the new team and redirects to its show' do
          post :create, params: { company_id: company, team_id: team, slack_configuration: { info_type: :current_week_throughput, room_webhook: 'http://xpto', notification_hour: 4 } }, xhr: true
          expect(SlackConfiguration.last.room_webhook).to eq 'http://xpto'
          expect(SlackConfiguration.last.info_type).to eq 'current_week_throughput'
          expect(SlackConfiguration.last.notification_hour).to eq 4
          expect(response).to render_template 'slack_configurations/create'
        end
      end

      context 'passing invalid parameters' do
        it 'does not create the team and re-render the template with the errors' do
          post :create, params: { company_id: company, team_id: team, slack_configuration: { room_webhook: '' } }, xhr: true
          expect(response).to render_template 'slack_configurations/new'
          expect(assigns(:slack_configuration).errors.full_messages).to eq ['Webhook da sala não pode ficar em branco', 'Hora para Notificar não pode ficar em branco']
        end
      end
    end
  end
end
