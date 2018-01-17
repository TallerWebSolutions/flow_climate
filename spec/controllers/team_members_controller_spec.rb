# frozen_string_literal: true

RSpec.describe TeamMembersController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', team_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', team_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', team_id: 'bar', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', team_id: 'bar', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PATCH #activate' do
      before { patch :activate, params: { company_id: 'xpto', team_id: 'bar', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PATCH #deactivate' do
      before { patch :activate, params: { company_id: 'xpto', team_id: 'bar', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:team) { Fabricate :team, company: company }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, team_id: team } }
        it 'instantiates a new Team Member and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:team_member)).to be_a_new TeamMember
        end
      end
      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo', team_id: team } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company, team_id: team } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      let(:company) { Fabricate :company, users: [user] }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, team_id: team, team_member: { name: 'foo', billable: false, active: false, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing } } }
        it 'creates the new team member and redirects to team show' do
          expect(TeamMember.last.name).to eq 'foo'
          expect(TeamMember.last.billable).to be false
          expect(TeamMember.last.active).to be false
          expect(TeamMember.last.monthly_payment).to eq 100
          expect(TeamMember.last.hours_per_month).to eq 10
          expect(TeamMember.last.billable_type).to eq 'outsourcing'
          expect(response).to redirect_to company_team_path(company, Team.last)
        end
      end
      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, team_id: team, team_member: { name: '' } } }
        it 'does not create the team member and re-render the template with the errors' do
          expect(TeamMember.last).to be_nil
          expect(response).to render_template :new
          expect(assigns(:team_member).errors.full_messages).to eq ['Nome não pode ficar em branco', 'Pagamento mensal não pode ficar em branco', 'Horas por mês não pode ficar em branco']
        end
      end
    end

    describe 'GET #edit' do
      let(:team) { Fabricate :team, company: company }
      let(:team_member) { Fabricate :team_member, team: team }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, team_id: team.id, id: team_member } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:team)).to eq team
          expect(assigns(:team_member)).to eq team_member
        end
      end

      context 'invalid' do
        context 'team_member' do
          before { get :edit, params: { company_id: company, team_id: team, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'team' do
          before { get :edit, params: { company_id: company, team_id: 'foo', id: team_member } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', team_id: team, id: team_member } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { get :edit, params: { company_id: company, team_id: team, id: team_member } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:team) { Fabricate :team, company: company }
      let(:team_member) { Fabricate :team_member, team: team }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, team_id: team, id: team_member, team_member: { name: 'foo', billable: false, active: false, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing } } }
        it 'creates the new project and redirects to projects index' do
          expect(TeamMember.last.name).to eq 'foo'
          expect(TeamMember.last.billable).to be false
          expect(TeamMember.last.active).to be false
          expect(TeamMember.last.monthly_payment.to_f).to be 100.0
          expect(TeamMember.last.hours_per_month).to be 10
          expect(TeamMember.last.billable_type).to eq 'outsourcing'
          expect(response).to redirect_to company_team_path(company, team)
        end
      end

      context 'passing invalid' do
        context 'team member parameters' do
          before { put :update, params: { company_id: company, team_id: team, id: team_member, team_member: { name: nil, billable: nil, active: nil, monthly_payment: nil, hours_per_month: nil, billable_type: nil } } }
          it 'does not create the project and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:team_member).errors.full_messages).to eq ['Nome não pode ficar em branco', 'Pagamento mensal não pode ficar em branco', 'Horas por mês não pode ficar em branco']
          end
        end
        context 'non-existent team' do
          before { put :update, params: { company_id: company, team_id: 'foo', id: team_member, team_member: { name: 'foo', billable: false, active: false, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent team member' do
          before { put :update, params: { company_id: company, team_id: team, id: 'foo', team_member: { name: 'foo', billable: false, active: false, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, team_id: team, id: team_member, team_member: { customer: customer.id, name: 'foo', status: :executing, project_type: :outsourcing, start_date: 1.day.ago, end_date: 1.day.from_now, value: 100.2, qty_hours: 300, hour_value: 200, initial_scope: 1000 } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PATCH #activate' do
      let(:team) { Fabricate :team, company: company }
      let(:team_member) { Fabricate :team_member, team: team }

      context 'passing valid parameters' do
        before { patch :activate, params: { company_id: company, team_id: team, id: team_member } }
        it 'creates the new project and redirects to projects index' do
          expect(TeamMember.last.active).to be true
          expect(response).to redirect_to company_team_path(company, team)
        end
      end

      context 'passing invalid' do
        context 'non-existent team member' do
          before { patch :activate, params: { company_id: company, team_id: team, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent team' do
          before { patch :update, params: { company_id: company, team_id: 'foo', id: team_member } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { patch :update, params: { company_id: company, team_id: team, id: team_member } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PATCH #deactivate' do
      let(:team) { Fabricate :team, company: company }
      let(:team_member) { Fabricate :team_member, team: team }

      context 'passing valid parameters' do
        before { patch :deactivate, params: { company_id: company, team_id: team, id: team_member } }
        it 'creates the new project and redirects to projects index' do
          expect(TeamMember.last.active).to be false
          expect(response).to redirect_to company_team_path(company, team)
        end
      end

      context 'passing invalid' do
        context 'non-existent team member' do
          before { patch :deactivate, params: { company_id: company, team_id: team, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent team' do
          before { patch :deactivate, params: { company_id: company, team_id: 'foo', id: team_member } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { patch :deactivate, params: { company_id: company, team_id: team, id: team_member } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
