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
    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user, first_name: 'zzz' }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
    let(:other_customer) { Fabricate :customer, company: company, name: 'aaa' }

    describe 'GET #new' do
      let!(:team) { Fabricate :team, company: company }
      let!(:first_project) { Fabricate :project, customer: customer }
      let!(:second_project) { Fabricate :project, customer: other_customer }
      let!(:third_project) { Fabricate :project, customer: customer }
      let!(:pipefy_config) { Fabricate :pipefy_config, project: third_project }

      it 'instantiates a new Company and renders the template' do
        get :new, params: { company_id: company }
        expect(response).to render_template :new
        expect(assigns(:pipefy_config)).to be_a_new PipefyConfig
        expect(assigns(:projects_to_select)).to eq [second_project, first_project]
      end
    end

    describe 'POST #create' do
      let!(:first_project) { Fabricate :project, customer: customer }
      let!(:second_project) { Fabricate :project, customer: other_customer }
      let!(:third_project) { Fabricate :project, customer: customer }
      let!(:other_pipefy_config) { Fabricate :pipefy_config, project: third_project }

      context 'passing valid parameters' do
        let!(:team) { Fabricate :team, company: company }
        before { post :create, params: { company_id: company, pipefy_config: { team_id: team, project_id: first_project, pipe_id: '332223' } } }
        it 'creates the new company and redirects to its show' do
          expect(PipefyConfig.last.team).to eq team
          expect(PipefyConfig.last.project).to eq first_project
          expect(PipefyConfig.last.pipe_id).to eq '332223'
          expect(response).to redirect_to company_path(company)
        end
      end
      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, pipefy_config: { pipe_id: '' } } }
        it 'does not create the company and re-render the template with the errors' do
          expect(PipefyConfig.count).to eq 1
          expect(response).to render_template :new
          expect(assigns(:projects_to_select)).to eq [second_project, first_project]
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

    describe 'GET #edit' do
      let(:pipefy_config) { Fabricate :pipefy_config, company: company }
      let!(:first_project) { Fabricate :project, customer: customer }
      let!(:second_project) { Fabricate :project, customer: other_customer }
      let!(:third_project) { Fabricate :project, customer: customer }
      let!(:other_pipefy_config) { Fabricate :pipefy_config, project: third_project }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, id: pipefy_config } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:pipefy_config)).to eq pipefy_config
          expect(assigns(:projects_to_select)).to eq [second_project, first_project]
        end
      end

      context 'invalid' do
        context 'pipefy config' do
          before { get :edit, params: { company_id: company, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', id: pipefy_config } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { get :edit, params: { company_id: company, id: pipefy_config } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:pipefy_config) { Fabricate :pipefy_config, company: company }
      let(:team) { Fabricate :team, company: company }
      let!(:first_project) { Fabricate :project, customer: customer }
      let!(:second_project) { Fabricate :project, customer: other_customer }
      let!(:third_project) { Fabricate :project, customer: customer }
      let!(:other_pipefy_config) { Fabricate :pipefy_config, company: company, project: third_project }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, id: pipefy_config, pipefy_config: { project_id: first_project, team_id: team, pipe_id: '100' } } }
        it 'updates the pipefy config and redirects to company show' do
          expect(PipefyConfig.last.company).to eq company
          expect(PipefyConfig.last.project).to eq first_project
          expect(PipefyConfig.last.team).to eq team
          expect(PipefyConfig.last.pipe_id).to eq '100'
          expect(response).to redirect_to company_path(company)
        end
      end

      context 'passing invalid' do
        context 'pipefy_config params' do
          before { put :update, params: { company_id: company, id: pipefy_config, pipefy_config: { project_id: 'xpto', team_id: '', pipe_id: '' } } }
          it 'does not update the pipefy config and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:projects_to_select)).to eq [second_project, first_project]
            expect(assigns(:pipefy_config).errors.full_messages).to match_array ['Id do Pipe não pode ficar em branco', 'Projeto não pode ficar em branco', 'Time não pode ficar em branco']
          end
        end
        context 'non-existent pipefy_config' do
          before { put :update, params: { company_id: company, id: 'foo', pipefy_config: { project_id: first_project, team_id: team, pipe_id: '100' } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, id: pipefy_config, product: { project_id: first_project, team_id: team, pipe_id: '100' } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
