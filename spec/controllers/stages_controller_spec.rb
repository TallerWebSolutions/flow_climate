# frozen_string_literal: true

RSpec.describe StagesController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { company_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'foo', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { company_id: 'foo', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }
    before { sign_in user }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company } }
        it 'instantiates a new Company and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:stage)).to be_a_new Stage
        end
      end

      context 'invalid parameters' do
        context 'inexistent company' do
          before { get :new, params: { company_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted' do
          let(:company) { Fabricate :company }
          before { get :new, params: { company_id: company } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, stage: { name: 'foo', integration_id: '332231', stage_type: :analysis, stage_stream: :downstream, commitment_point: true, end_point: true, queue: true, compute_effort: true, percentage_effort: 30.3 } } }
        it 'creates the new financial information to the company and redirects to its show' do
          created_stage = Stage.last
          expect(created_stage.company).to eq company
          expect(created_stage.name).to eq 'foo'
          expect(created_stage.stage_type).to eq 'analysis'
          expect(created_stage.stage_stream).to eq 'downstream'
          expect(created_stage.commitment_point?).to be true
          expect(created_stage.end_point?).to be true
          expect(created_stage.queue?).to be true
          expect(created_stage.compute_effort?).to be true
          expect(created_stage.percentage_effort).to eq 30.3
          expect(response).to redirect_to company_path(Company.last)
        end
      end
      context 'passing invalid parameters' do
        context 'invalid attributes' do
          before { post :create, params: { company_id: company, stage: { name: nil, integration_id: nil, stage_type: nil, stage_stream: nil, commitment_point: nil, end_point: nil, queue: nil, compute_effort: nil, percentage_effort: nil } } }
          it 'does not create the company and re-render the template with the errors' do
            expect(Stage.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:stage).errors.full_messages).to eq ['Id na Integração não pode ficar em branco', 'Nome não pode ficar em branco', 'Tipo da Etapa não pode ficar em branco', 'Tipo do Stream não pode ficar em branco']
          end
        end
        context 'inexistent company' do
          before { post :create, params: { company_id: 'foo', stage: { name: 'foo', integration_id: '332231', stage_type: :analysis, stage_stream: :downstream, commitment_point: true, end_point: true, queue: true, compute_effort: true, percentage_effort: 30.3 } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted company' do
          let(:company) { Fabricate :company }
          before { post :create, params: { company_id: company, stage: { name: 'foo', integration_id: '332231', stage_type: :analysis, stage_stream: :downstream, commitment_point: true, end_point: true, queue: true, compute_effort: true, percentage_effort: 30.3 } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let(:company) { Fabricate :company, users: [user] }
      let(:stage) { Fabricate :stage, company: company }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, id: stage } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:stage)).to eq stage
        end
      end

      context 'invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', id: stage } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { get :edit, params: { company_id: company, id: stage } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:company) { Fabricate :company, users: [user] }
      let(:stage) { Fabricate :stage, company: company }

      context 'passing valid parameters' do
        it 'updates the demand and redirects to projects index' do
          put :update, params: { company_id: company, id: stage, stage: { name: 'foo', integration_id: '332231', stage_type: :analysis, stage_stream: :downstream, commitment_point: true, end_point: true, queue: true, compute_effort: true, percentage_effort: 30.3 } }
          updated_stage = stage.reload
          expect(updated_stage.company).to eq company
          expect(updated_stage.name).to eq 'foo'
          expect(updated_stage.stage_type).to eq 'analysis'
          expect(updated_stage.stage_stream).to eq 'downstream'
          expect(updated_stage.commitment_point?).to be true
          expect(updated_stage.end_point?).to be true
          expect(updated_stage.queue?).to be true
          expect(updated_stage.compute_effort?).to be true
          expect(updated_stage.percentage_effort).to eq 30.3
          expect(response).to redirect_to company_path(Company.last)
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          before { put :update, params: { company_id: company, id: stage, stage: { name: nil, integration_id: nil, stage_type: nil, stage_stream: nil, commitment_point: nil, end_point: nil, queue: nil, compute_effort: nil, percentage_effort: nil } } }
          it { expect(assigns(:stage).errors.full_messages).to match_array ['Id na Integração não pode ficar em branco', 'Nome não pode ficar em branco', 'Tipo da Etapa não pode ficar em branco', 'Tipo do Stream não pode ficar em branco'] }
        end
        context 'non-stage' do
          before { put :update, params: { company_id: company, id: 'foo', stage: { name: 'foo' } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'company' do
          context 'non-existent' do
            before { put :update, params: { company_id: 'foo', id: stage, stage: { name: 'foo' } } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { put :update, params: { company_id: company, id: stage, stage: { name: 'foo' } } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:stage) { Fabricate :stage, company: company }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, id: stage } }
          it 'deletes the stage and redirects' do
            expect(response).to redirect_to company_path(company)
            expect(Stage.last).to be_nil
          end
        end
        context 'having dependencies' do
          let(:project) { Fabricate :project }
          let!(:stage) { Fabricate :stage, company: company, projects: [project] }
          let(:demand) { Fabricate :demand, project: project }
          let!(:demand_transition) { Fabricate :demand_transition, stage: stage, demand: demand }
          before { delete :destroy, params: { company_id: company, id: stage } }

          it 'does not delete the stage and show the errors' do
            expect(response).to redirect_to company_path(company)
            expect(Stage.last).to eq stage
            expect(flash[:error]).to eq assigns(:stage).errors.full_messages.join(',')
          end
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent stage' do
          before { delete :destroy, params: { company_id: company, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'company' do
          context 'non-existent' do
            before { delete :destroy, params: { company_id: 'foo', id: stage } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { delete :destroy, params: { company_id: company, id: stage } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
