# frozen_string_literal: true

RSpec.describe DemandTransitionsController, type: :controller do
  context 'unauthenticated' do
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', stage_id: 'bar', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', demand_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', demand_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as gold' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:team) { Fabricate :team, company: company }
    let(:project) { Fabricate :project, customers: [customer], team: team }
    let!(:demand) { Fabricate :demand, project: project, team: team }
    let!(:stage) { Fabricate :stage, company: company, projects: [project] }

    before { sign_in user }

    describe 'DELETE #destroy' do
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage }

      context 'passing valid IDs' do
        before { delete :destroy, params: { company_id: company, stage_id: stage, id: demand_transition } }

        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_stage_path(company, stage)
          expect(DemandTransition.last).to be_nil
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', stage_id: stage, id: demand_transition } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent stage' do
          before { delete :destroy, params: { company_id: company, stage_id: 'foo', id: demand_transition } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, stage_id: stage, id: demand_transition } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, demand_id: demand }, xhr: true }

        it 'instantiates a new Team Member and renders the template' do
          expect(response).to render_template 'demand_transitions/new'
          expect(assigns(:demand_transition)).to be_a_new DemandTransition
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo', demand_id: demand }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company, demand_id: demand }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        let!(:first_stage) { Fabricate :stage, company: company, teams: [team], order: 1 }
        let!(:second_stage) { Fabricate :stage, company: company, teams: [team], order: 0 }

        before { post :create, params: { company_id: company, demand_id: demand, demand_transition: { stage_id: stage, last_time_in: 3.days.ago, last_time_out: 1.day.ago } }, xhr: true }

        it 'creates the new demand transition' do
          expect(response).to render_template 'demand_transitions/create'
          expect(assigns(:demand_transition).errors.full_messages).to eq []
          expect(assigns(:demand_transition)).to be_persisted
          expect(assigns(:demand_transition).stage).to eq stage
          expect(assigns(:stages_to_select)).to eq [second_stage, first_stage]
        end
      end

      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, demand_id: demand, demand_transition: { stage_id: nil, last_time_in: nil, last_time_out: nil } }, xhr: true }

        it 'does not create the transition and re-render the template with the errors' do
          expect(DemandTransition.all.count).to eq 0
          expect(response).to render_template 'demand_transitions/create'
          expect(assigns(:demand_transition).errors.full_messages).to eq ['Etapa não pode ficar em branco', 'Entrada não pode ficar em branco']
        end
      end
    end
  end
end
