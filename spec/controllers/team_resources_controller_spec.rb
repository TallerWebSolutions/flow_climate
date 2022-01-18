# frozen_string_literal: true

RSpec.describe TeamResourcesController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', id: 'xpto' } }

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

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company }, xhr: true }

        it 'instantiates a new Team Resource and renders the template' do
          expect(response).to render_template 'team_resources/new'
          expect(assigns(:team_resource)).to be_a_new TeamResource
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, team_resource: { resource_type: :library_manager, resource_name: 'foo' } }, xhr: true }

        it 'creates the new team resource and redirects to team show' do
          expect(response).to render_template 'team_resources/create'
          expect(assigns(:team_resource).errors.full_messages).to eq []
          expect(assigns(:team_resource)).to be_persisted
          expect(assigns(:team_resource).resource_type).to eq 'library_manager'
          expect(assigns(:team_resource).resource_name).to eq 'foo'
        end
      end

      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, team_resource: { resource_type: nil } }, xhr: true }

        it 'does not create the team resource and re-render the template with the errors' do
          expect(TeamResource.all.count).to eq 0
          expect(response).to render_template 'team_resources/create'
          expect(assigns(:team_resource).errors.full_messages).to eq ['Tipo do Recurso não pode ficar em branco']
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:team_resource) { Fabricate :team_resource, company: company }
      let!(:other_team_resource) { Fabricate :team_resource }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, id: team_resource }, xhr: true }

          it 'deletes the product and redirects' do
            expect(response).to render_template 'team_resources/destroy'
            expect(TeamResource.all).to eq [other_team_resource]
          end
        end
      end

      context 'passing an invalid ID' do
        context 'other company' do
          before { delete :destroy, params: { company_id: company, id: other_team_resource } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', id: team_resource } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, id: team_resource } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
