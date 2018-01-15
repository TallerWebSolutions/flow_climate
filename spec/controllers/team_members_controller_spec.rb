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
        before { post :create, params: { company_id: company, team_id: team, team_member: { name: 'foo', monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing } } }
        it 'creates the new team member and redirects to team show' do
          expect(TeamMember.last.name).to eq 'foo'
          expect(TeamMember.last.monthly_payment).to eq 100
          expect(TeamMember.last.hours_per_month).to eq 10
          expect(TeamMember.last.billable_type).to eq 'outsourcing'
          expect(response).to redirect_to company_team_path(company, Team.last)
        end
      end
      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, team_id: team, team_member: { name: '' } } }
        it 'does not create the company and re-render the template with the errors' do
          expect(TeamMember.last).to be_nil
          expect(response).to render_template :new
          expect(assigns(:team_member).errors.full_messages).to eq ['Nome não pode ficar em branco', 'Pagamento mensal não pode ficar em branco', 'Horas por mês não pode ficar em branco']
        end
      end
    end
  end
end
