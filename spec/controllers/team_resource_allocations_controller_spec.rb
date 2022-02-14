# frozen_string_literal: true

RSpec.describe TeamResourceAllocationsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', team_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', team_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', team_id: 'bar', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer }
    let(:team) { Fabricate :team, company: company }
    let!(:team_resource) { Fabricate :team_resource, company: company }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, team_id: team }, xhr: true }

        it 'instantiates a new Team Member and renders the template' do
          expect(response).to render_template 'team_resource_allocations/new'
          expect(assigns(:team_resource_allocation)).to be_a_new TeamResourceAllocation
          expect(assigns(:team_resources)).to eq [team_resource]
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
        before { post :create, params: { company_id: company, team_id: team, team_resource_allocation: { team_resource_id: team_resource.id, start_date: 2.days.ago, end_date: 1.day.ago, monthly_payment: 1000 } }, xhr: true }

        it 'creates the new team resource allocation and redirects to team show' do
          expect(response).to render_template 'team_resource_allocations/create'
          expect(assigns(:team_resource_allocation).errors.full_messages).to eq []
          expect(assigns(:team_resource_allocation)).to be_persisted
          expect(assigns(:team_resource_allocation).team_resource).to eq team_resource
          expect(assigns(:team_resource_allocation).start_date).to eq 2.days.ago.to_date
          expect(assigns(:team_resource_allocation).end_date).to eq 1.day.ago.to_date
          expect(assigns(:team_resource_allocation).monthly_payment).to eq 1000

          expect(assigns(:team_resource_allocations)).to eq team.team_resource_allocations.order(:start_date)
          expect(assigns(:team_resources)).to eq [team_resource]
        end
      end

      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, team_id: team, team_resource_allocation: { team_resource_id: nil, start_date: nil, end_date: nil, monthly_payment: nil } }, xhr: true }

        it 'does not create the team member allocation and re-render the template with the errors' do
          expect(TeamResource.all.count).to eq 1
          expect(TeamResourceAllocation.all.count).to eq 0
          expect(response).to render_template 'team_resource_allocations/create'
          expect(assigns(:team_resource_allocation).errors.full_messages).to eq ['Recurso do Time deve existir', 'Início não pode ficar em branco', 'Pagamento Mensal não pode ficar em branco']
        end
      end
    end

    describe 'DELETE #destroy' do
      let!(:first_team_resource_allocation) { Fabricate :team_resource_allocation, team: team, team_resource: team_resource }
      let!(:second_team_other_resource_allocation) { Fabricate :team_resource_allocation, team: team, team_resource: team_resource }
      let!(:other_team_resource_allocation) { Fabricate :team_resource_allocation, team_resource: team_resource }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, team_id: team, id: first_team_resource_allocation }, xhr: true }

          it 'deletes the product and redirects' do
            expect(response).to have_http_status :ok
            expect(response).to render_template 'team_resource_allocations/destroy'
            expect(assigns(:team_resource_allocations)).to eq [second_team_other_resource_allocation]
            expect(TeamResourceAllocation.all).to match_array [other_team_resource_allocation, second_team_other_resource_allocation]
          end
        end
      end

      context 'passing an invalid ID' do
        context 'other company' do
          before { delete :destroy, params: { company_id: company, team_id: team, id: other_team_resource_allocation }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', team_id: team, id: first_team_resource_allocation }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, team_id: team, id: first_team_resource_allocation }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
