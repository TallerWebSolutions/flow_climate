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
          expect(Stage.last.company).to eq company
          expect(Stage.last.name).to eq 'foo'
          expect(Stage.last.stage_type).to eq 'analysis'
          expect(Stage.last.stage_stream).to eq 'downstream'
          expect(Stage.last.commitment_point?).to be true
          expect(Stage.last.end_point?).to be true
          expect(Stage.last.queue?).to be true
          expect(Stage.last.compute_effort?).to be true
          expect(Stage.last.percentage_effort).to eq 30.3
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
  end
end
