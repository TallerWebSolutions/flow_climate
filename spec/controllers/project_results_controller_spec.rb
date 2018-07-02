# frozen_string_literal: true

RSpec.describe ProjectResultsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { company_id: 'xpto', project_id: 'bar', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'GET #show' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }
      let!(:project) { Fabricate :project, customer: product.customer, product: product, end_date: 5.days.from_now }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:first_demand) { Fabricate :demand, project_result: project_result, end_date: Time.zone.today, demand_id: 'ZZZ' }
      let!(:second_demand) { Fabricate :demand, project_result: project_result, end_date: Time.zone.today, demand_id: 'AAA' }
      let!(:third_demand) { Fabricate :demand, project_result: project_result, end_date: Time.zone.today, demand_id: 'BBB', discarded_at: Time.zone.now }

      context 'passing a valid ID' do
        context 'having data' do
          before { get :show, params: { company_id: company, project_id: project, id: project_result } }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:project)).to eq project
            expect(assigns(:project_result)).to eq project_result
            expect(assigns(:demands)[[Time.zone.today.cwyear, Time.zone.today.month]]).to match_array [second_demand, first_demand]
          end
        end
        context 'having no data' do
          let(:empty_project_result) { Fabricate :project_result, project: project }
          before { get :show, params: { company_id: company, project_id: project, id: empty_project_result } }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:project)).to eq project
            expect(assigns(:project_result)).to eq empty_project_result
            expect(assigns(:demands)).to eq({})
          end
        end
      end
      context 'passing invalid parameters' do
        context 'non-existent company' do
          before { get :show, params: { company_id: 'foo', project_id: project, id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent project_result' do
          before { get :show, params: { company_id: company, project_id: project, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { get :show, params: { company_id: company, project_id: project, id: product } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
