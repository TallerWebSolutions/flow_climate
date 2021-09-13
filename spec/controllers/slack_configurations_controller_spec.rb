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

    describe 'PATCH #toggle_active' do
      before { patch :toggle_active, params: { company_id: 'bar', team_id: 'foo', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'bar', team_id: 'foo', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'bar', team_id: 'foo', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #index' do
      before { get :index, params: { company_id: 'bar', team_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as gold' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }

    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:team) { Fabricate :team, company: company }

    let!(:first_slack_config) { Fabricate :slack_configuration, team: team, info_type: :last_week_delivered_demands_info, created_at: 1.hour.ago, active: true }
    let!(:second_slack_config) { Fabricate :slack_configuration, team: team, info_type: :outdated_demands, created_at: 1.day.ago, active: true }

    describe 'GET #new' do
      context 'valid parameters' do
        it 'instantiates a new Slack Config and renders the template' do
          get :new, params: { company_id: company, team_id: team }, xhr: true

          expect(response).to render_template 'slack_configurations/new'
          expect(assigns(:slack_configurations)).to eq [second_slack_config, first_slack_config]
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
      let(:stage) { Fabricate :stage }
      let(:other_stage) { Fabricate :stage }

      context 'passing valid parameters' do
        it 'creates the new slack config and renders the table' do
          post :create, params: { company_id: company, team_id: team, "stage_#{stage.id}" => stage.id, "stage_#{other_stage.id}" => other_stage.id, slack_configuration: { info_type: :demand_state_changed, room_webhook: 'http://xpto', notification_hour: 4, notification_minute: 0, weekday_to_notify: :monday } }, xhr: true

          config_created = SlackConfiguration.last
          expect(config_created.room_webhook).to eq 'http://xpto'
          expect(config_created.info_type).to eq 'demand_state_changed'
          expect(config_created.notification_hour).to eq 4
          expect(config_created.notification_minute).to eq 0
          expect(config_created.weekday_to_notify).to eq 'monday'
          expect(config_created.stages_to_notify_transition).to match_array [stage.id, other_stage.id]
          expect(assigns(:slack_configurations)).to eq [second_slack_config, first_slack_config, config_created]
          expect(response).to render_template 'slack_configurations/create_update'
        end
      end

      context 'passing invalid parameters' do
        it 'does not create the slack config and re-render the template with the errors' do
          post :create, params: { company_id: company, team_id: team, slack_configuration: { room_webhook: '' } }, xhr: true
          expect(response).to render_template 'slack_configurations/new'
          expect(assigns(:slack_configuration).errors.full_messages).to eq ['Webhook da sala não pode ficar em branco', 'Webhook da sala não é válido']
        end
      end
    end

    describe 'PATCH #toggle_admin' do
      let(:slack_config) { Fabricate :slack_configuration, team: team, active: true }

      context 'with valid parameters' do
        context 'and activated slack config' do
          it 'deactivate the slack configuration' do
            patch :toggle_active, params: { company_id: company, team_id: team, id: slack_config }, xhr: true
            expect(slack_config.reload.active).to be false
            expect(response).to render_template 'slack_configurations/toggle_active'
          end
        end

        context 'and inactive slack config' do
          let!(:inactive_slack_config) { Fabricate :slack_configuration, team: team, info_type: :failure_load, active: false }

          it 'deactivate the slack configuration' do
            patch :toggle_active, params: { company_id: company, team_id: team, id: inactive_slack_config }, xhr: true
            expect(slack_config.reload.active).to be true
            expect(response).to render_template 'slack_configurations/toggle_active'
          end
        end
      end

      context 'with invalid' do
        context 'company' do
          before { patch :toggle_active, params: { company_id: 'foo', team_id: team, id: slack_config }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'team' do
          before { patch :toggle_active, params: { company_id: company, team_id: 'foo', id: slack_config }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'slack config' do
          before { patch :toggle_active, params: { company_id: company, team_id: team, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let(:slack_config) { Fabricate :slack_configuration, team: team, active: true }

      context 'with valid parameters' do
        it 'finds the slack config and renders the form' do
          get :edit, params: { company_id: company, team_id: team, id: slack_config }, xhr: true

          expect(assigns(:slack_configurations)).to eq [second_slack_config, first_slack_config, slack_config]
          expect(response).to render_template 'slack_configurations/edit'
          expect(assigns(:slack_configuration)).to eq slack_config
        end
      end

      context 'with invalid' do
        context 'company' do
          before { get :edit, params: { company_id: 'foo', team_id: team, id: slack_config }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :edit, params: { company_id: company, team_id: team, id: slack_config }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'team' do
          before { get :edit, params: { company_id: company, team_id: 'foo', id: slack_config }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'slack_configuration' do
          before { get :edit, params: { company_id: company, team_id: team, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PUT #update' do
      let(:slack_config) { Fabricate :slack_configuration, team: team, active: true }
      let(:stage) { Fabricate :stage }
      let(:other_stage) { Fabricate :stage }

      context 'passing valid parameters' do
        it 'updates the slack config' do
          put :update, params: { company_id: company, team_id: team, id: slack_config, "stage_#{stage.id}" => stage.id, "stage_#{other_stage.id}" => other_stage.id, slack_configuration: { info_type: :demand_state_changed, room_webhook: 'http://xpto', notification_hour: 4, notification_minute: 0, weekday_to_notify: :monday } }, xhr: true

          expect(assigns(:slack_configurations)).to eq [second_slack_config, first_slack_config, slack_config]

          slack_config_updated = slack_config.reload
          expect(slack_config_updated.room_webhook).to eq 'http://xpto'
          expect(slack_config_updated.info_type).to eq 'demand_state_changed'
          expect(slack_config_updated.notification_hour).to eq 4
          expect(slack_config_updated.notification_minute).to eq 0
          expect(slack_config_updated.weekday_to_notify).to eq 'monday'
          expect(slack_config_updated.stages_to_notify_transition).to match_array [stage.id, other_stage.id]
          expect(response).to render_template 'slack_configurations/create_update'
        end
      end

      context 'passing invalid parameters' do
        it 'does not update the slack config and re-renders the form' do
          put :update, params: { company_id: company, team_id: team, id: slack_config, slack_configuration: { room_webhook: '' } }, xhr: true
          expect(response).to render_template 'slack_configurations/edit'
          expect(assigns(:slack_configuration).errors.full_messages).to eq ['Webhook da sala não pode ficar em branco', 'Webhook da sala não é válido']
        end
      end
    end

    describe 'GET #index' do
      context 'valid parameters' do
        before { get :index, params: { company_id: company, team_id: team } }

        it 'assigns the slack configurations variable and renders the templates' do
          expect(response).to render_template 'slack_configurations/index'
          expect(response).to render_template 'slack_configurations/_slack_config_table'
          expect(assigns(:slack_configurations)).to eq [second_slack_config, first_slack_config]
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :index, params: { company_id: 'foo', team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :index, params: { company_id: company, team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
