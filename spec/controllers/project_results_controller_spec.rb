# frozen_string_literal: true

RSpec.describe ProjectResultsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :new, params: { company_id: 'xpto', project_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { company_id: 'xpto', project_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'GET #new' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
      let!(:project) { Fabricate :project, customer: customer, end_date: 5.days.from_now }

      context 'passing valid IDs' do
        before { get :new, params: { company_id: company, project_id: project } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:project_result)).to be_a_new ProjectResult
          expect(assigns(:project_result).project).to eq project
        end
      end
      context 'passing an invalid ID' do
        context 'non-existent project' do
          before { get :new, params: { company_id: company, project_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo', project_id: project } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { get :new, params: { company_id: company, project_id: project } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customer: customer, end_date: 2.days.from_now }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, project_id: project, project_result: { result_date: Time.zone.today, qty_hours_upstream: 10, qty_hours_downstream: 13, throughput: 5, qty_bugs_opened: 0, qty_bugs_closed: 3, qty_hours_bug: 7, leadtime: 10.5, histogram_first_mode: 12.2, histogram_second_mode: 9.2 } } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_project_path(company, project)
          result = ProjectResult.last
          expect(result.project).to eq project
          expect(result.result_date).to eq Time.zone.today
          expect(result.qty_hours_upstream).to eq 10
          expect(result.qty_hours_downstream).to eq 13
          expect(result.throughput).to eq 5
          expect(result.qty_bugs_opened).to eq 0
          expect(result.qty_bugs_closed).to eq 3
          expect(result.qty_hours_bug).to eq 7
          expect(result.leadtime).to eq 10.5
          expect(result.histogram_first_mode.to_f).to eq 12.2
          expect(result.histogram_second_mode.to_f).to eq 9.2
        end
      end
      context 'passing invalid' do
        context 'company' do
          before { post :create, params: { company_id: 'foo', project_id: project, project_result: { result_date: Time.zone.today, qty_hours_upstream: 10, qty_hours_downstream: 13, throughput: 5, qty_bugs_opened: 0, qty_bugs_closed: 3, qty_hours_bug: 7, leadtime: 10.5, histogram_first_mode: 12.2, histogram_second_mode: 9.2 } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project' do
          before { post :create, params: { company_id: company, project_id: 'foo', project_result: { result_date: Time.zone.today, qty_hours_upstream: 10, qty_hours_downstream: 13, throughput: 5, qty_bugs_opened: 0, qty_bugs_closed: 3, qty_hours_bug: 7, leadtime: 10.5, histogram_first_mode: 12.2, histogram_second_mode: 9.2 } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'results parameters' do
          before { post :create, params: { company_id: company, project_id: project, project_result: { result_date: nil, qty_hours_upstream: nil, qty_hours_downstream: nil, throughput: nil, qty_bugs_opened: nil, qty_bugs_closed: nil, qty_hours_bug: nil, leadtime: nil, histogram_first_mode: nil, histogram_second_mode: nil } } }
          it 'renders the template again showing the errors' do
            expect(response).to render_template :new
            expect(assigns(:project_result).errors.full_messages).to eq ['Horas em Bugs não pode ficar em branco', 'Bugs Fechados não pode ficar em branco', 'Bugs Abertos não pode ficar em branco', 'Throughput não pode ficar em branco', 'Data não pode ficar em branco']
          end
        end
      end
    end
  end
end
