# frozen_string_literal: true

RSpec.describe PipefyTeamConfigsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', team_id: 'bar', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', team_id: 'bar', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:team) { Fabricate :team, company: company }

    describe 'GET #edit' do
      let(:team) { Fabricate :team, company: company }
      let(:pipefy_team_config) { Fabricate :pipefy_team_config, team: team }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, team_id: team.id, id: pipefy_team_config } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:team)).to eq team
          expect(assigns(:pipefy_team_config)).to eq pipefy_team_config
        end
      end

      context 'invalid' do
        context 'pipefy_team_config' do
          before { get :edit, params: { company_id: company, team_id: team, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'team' do
          before { get :edit, params: { company_id: company, team_id: 'foo', id: pipefy_team_config } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', team_id: team, id: pipefy_team_config } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { get :edit, params: { company_id: company, team_id: team, id: pipefy_team_config } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:team) { Fabricate :team, company: company }
      let(:other_team) { Fabricate :team, company: company }
      let(:pipefy_team_config) { Fabricate :pipefy_team_config, team: team }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, team_id: team, id: pipefy_team_config, pipefy_team_config: { member_type: :analyst, username: 'foo', integration_id: '2221' } } }
        it 'updates the member and redirects to team show' do
          expect(PipefyTeamConfig.last.member_type).to eq 'analyst'
          expect(PipefyTeamConfig.last.username).to eq 'foo'
          expect(PipefyTeamConfig.last.integration_id).to eq '2221'
          expect(response).to redirect_to company_team_path(company, team)
        end
      end

      context 'passing invalid' do
        context 'pipefy team config parameters' do
          before { put :update, params: { company_id: company, team_id: team, id: pipefy_team_config, pipefy_team_config: { member_type: nil, username: nil, integration_id: nil } } }
          it 'does not update the member and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:pipefy_team_config).errors.full_messages).to eq ['Id na Integração não pode ficar em branco', 'Nome do Usuário não pode ficar em branco']
          end
        end
        context 'non-existent team' do
          before { put :update, params: { company_id: company, team_id: 'foo', id: pipefy_team_config, pipefy_team_config: { team: other_team, name: 'foo', billable: false, active: false, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent pipefy team config' do
          before { put :update, params: { company_id: company, team_id: team, id: 'foo', pipefy_team_config: { team: other_team, name: 'foo', billable: false, active: false, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { put :update, params: { company_id: company, team_id: team, id: pipefy_team_config, pipefy_team_config: { team: other_team, name: 'foo', billable: false, active: false, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
