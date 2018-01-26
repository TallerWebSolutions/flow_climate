# frozen_string_literal: true

RSpec.describe DemandsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }
    let(:project) { Fabricate :project, customer: customer, product: product }

    before { sign_in user }

    describe 'GET #new' do
      let(:project_result) { Fabricate :project_result, project: project }

      context 'valid parameters' do
        before { get :new, params: { company_id: company, project_id: project, project_result_id: project_result } }
        it 'instantiates a new Company and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:project_result)).to eq project_result
          expect(assigns(:demand)).to be_a_new Demand
        end
      end

      context 'invalid parameters' do
        context 'inexistent company' do
          before { get :new, params: { company_id: 'foo', project_id: project, project_result_id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'inexistent project' do
          before { get :new, params: { company_id: company, project_id: 'foo', project_result_id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'inexistent project_result' do
          before { get :new, params: { company_id: company, project_id: project, project_result_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted' do
          let(:company) { Fabricate :company }
          before { get :new, params: { company_id: company, project_id: project, project_result_id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      let(:project_result) { Fabricate :project_result, project: project }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, project_id: project, project_result_id: project_result, demand: { demand_id: 'xpto', effort: 5 } } }
        it 'creates the new financial information to the company and redirects to its show' do
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:project_result)).to eq project_result

          expect(Demand.last.project_result).to eq project_result
          expect(Demand.last.demand_id).to eq 'xpto'
          expect(Demand.last.effort).to eq 5
          expect(response).to redirect_to company_project_project_result_path(company, project, project_result)
        end
      end
      context 'passing invalid parameters' do
        context 'invalid attributes' do
          before { post :create, params: { company_id: company, project_id: project, project_result_id: project_result, demand: { finances: nil, income_total: nil, expenses_total: nil } } }
          it 'does not create the company and re-render the template with the errors' do
            expect(Demand.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:demand).errors.full_messages).to eq ['Id da Demanda não pode ficar em branco', 'Esforço não pode ficar em branco']
          end
        end
        context 'inexistent company' do
          before { post :create, params: { company_id: 'foo', project_id: project, project_result_id: project_result, demand: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'inexistent project' do
          before { post :create, params: { company_id: company, project_id: 'foo', project_result_id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'inexistent project_result' do
          before { post :create, params: { company_id: company, project_id: project, project_result_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted company' do
          let(:company) { Fabricate :company }
          before { post :create, params: { company_id: company, project_id: project, project_result_id: project_result, demand: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
