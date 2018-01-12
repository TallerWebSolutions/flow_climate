# frozen_string_literal: true

RSpec.describe ProjectsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { company_id: 'xpto', customer_id: 'bar', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #index' do
      before { get :index, params: { company_id: 'xpto', customer_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'GET #show' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
      let!(:first_project) { Fabricate :project, customer: customer, end_date: 5.days.from_now }

      context 'passing valid IDs' do
        before { get :show, params: { company_id: company, customer_id: customer, id: first_project } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template :show
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq first_project
        end
      end
      context 'passing an invalid ID' do
        context 'non-existent' do
          before { get :show, params: { company_id: company, customer_id: customer, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { get :show, params: { company_id: company, customer_id: customer, id: first_project } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #index' do
      context 'not passing status filter' do
        let(:company) { Fabricate :company, users: [user] }
        let(:customer) { Fabricate :customer, company: company }
        let!(:project) { Fabricate :project, customer: customer, end_date: 5.days.from_now }
        let!(:other_project) { Fabricate :project, customer: customer, end_date: 2.days.from_now }
        let!(:other_company_project) { Fabricate :project, end_date: 2.days.from_now }
        before { get :index, params: { company_id: company } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template :index
          projects = assigns(:projects)
          expect(projects).to eq [other_project, project]
          expect(assigns(:total_hours)).to eq projects.sum(&:qty_hours)
          expect(assigns(:average_hour_value)).to eq projects.average(:hour_value)
          expect(assigns(:total_value)).to eq projects.sum(:value)
        end
      end
      context 'passing status filter' do
        let(:company) { Fabricate :company, users: [user] }
        let(:customer) { Fabricate :customer, company: company }
        let!(:project) { Fabricate :project, customer: customer, status: :executing }
        let!(:other_project) { Fabricate :project, customer: customer, status: :waiting }
        let!(:other_company_project) { Fabricate :project, status: :executing }
        before { get :index, params: { company_id: company, status_filter: :executing } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template :index
          expect(assigns(:projects)).to eq [project]
        end
      end
    end
  end
end
