# frozen_string_literal: true

RSpec.describe PipefyConfigsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { company_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user, first_name: 'zzz' }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }

    describe 'GET #new' do
      let!(:team) { Fabricate :team, company: company }
      let!(:project) { Fabricate :project, customer: customer }
      before { get :new, params: { company_id: company } }
      it 'instantiates a new Company and renders the template' do
        expect(response).to render_template :new
        expect(assigns(:pipefy_config)).to be_a_new PipefyConfig
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        let!(:team) { Fabricate :team, company: company }
        let(:customer) { Fabricate :customer, company: company }
        let!(:project) { Fabricate :project, customer: customer }
        before { post :create, params: { company_id: company, pipefy_config: { team_id: team, project_id: project, pipe_id: '332223' } } }
        it 'creates the new company and redirects to its show' do
          expect(PipefyConfig.last.team).to eq team
          expect(PipefyConfig.last.project).to eq project
          expect(PipefyConfig.last.pipe_id).to eq '332223'
          expect(response).to redirect_to company_path(company)
        end
      end
      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, pipefy_config: { pipe_id: '' } } }
        it 'does not create the company and re-render the template with the errors' do
          expect(PipefyConfig.last).to be_nil
          expect(response).to render_template :new
          expect(assigns(:pipefy_config).errors.full_messages).to eq ['Projeto não pode ficar em branco', 'Id do Pipe não pode ficar em branco', 'Time não pode ficar em branco']
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:pipefy_config) { Fabricate :pipefy_config, company: company }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, id: pipefy_config } }
          it 'deletes the customer and redirects' do
            expect(response).to redirect_to company_path(company)
            expect(PipefyConfig.last).to be_nil
          end
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent pipefy_config' do
          before { delete :destroy, params: { company_id: company, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', id: pipefy_config } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { delete :destroy, params: { company_id: company, id: pipefy_config } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
