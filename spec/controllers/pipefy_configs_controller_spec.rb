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
  end
end
