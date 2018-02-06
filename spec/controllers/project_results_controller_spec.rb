# frozen_string_literal: true

RSpec.describe ProjectResultsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { company_id: 'xpto', project_id: 'bar', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #new' do
      before { get :new, params: { company_id: 'xpto', project_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { company_id: 'xpto', project_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'xpto', project_id: 'bar', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', project_id: 'bla', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', project_id: 'bla', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'GET #new' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let!(:project) { Fabricate :project, customer: customer, product: product, end_date: 5.days.from_now }

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
      let(:team) { Fabricate :team, company: company }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
      let!(:project) { Fabricate :project, customer: customer, product: product, end_date: 2.days.from_now }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, project_id: project, project_result: { team: team.id, result_date: Time.zone.today, known_scope: 100, qty_hours_upstream: 10, qty_hours_downstream: 13, throughput: 5, monte_carlo_date: 1.month.from_now, qty_bugs_opened: 0, qty_bugs_closed: 3, qty_hours_bug: 7, leadtime: 10.5 } } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_project_path(company, project)
          result = ProjectResult.last
          expect(result.team).to eq team
          expect(result.project).to eq project
          expect(result.result_date).to eq Time.zone.today
          expect(result.qty_hours_upstream).to eq 10
          expect(result.qty_hours_downstream).to eq 13
          expect(result.throughput).to eq 5
          expect(result.monte_carlo_date).to eq 1.month.from_now.to_date
          expect(result.qty_bugs_opened).to eq 0
          expect(result.qty_bugs_closed).to eq 3
          expect(result.qty_hours_bug).to eq 7
          expect(result.leadtime).to eq 10.5
          expect(result.flow_pressure.to_f).to eq 50.0
          expect(result.remaining_days).to eq 2
        end
      end
      context 'passing invalid' do
        context 'company' do
          before { post :create, params: { company_id: 'foo', project_id: project, project_result: { result_date: Time.zone.today, qty_hours_upstream: 10, qty_hours_downstream: 13, throughput: 5, qty_bugs_opened: 0, qty_bugs_closed: 3, qty_hours_bug: 7, leadtime: 10.5 } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'project' do
          before { post :create, params: { company_id: company, project_id: 'foo', project_result: { result_date: Time.zone.today, qty_hours_upstream: 10, qty_hours_downstream: 13, throughput: 5, qty_bugs_opened: 0, qty_bugs_closed: 3, qty_hours_bug: 7, leadtime: 10.5 } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'results parameters' do
          before { post :create, params: { company_id: company, project_id: project, project_result: { result_date: nil } } }
          it 'renders the template again showing the errors' do
            expect(response).to render_template :new
            expect(assigns(:project_result).errors.full_messages).to eq ['Time não pode ficar em branco', 'Escopo Conhecido não pode ficar em branco', 'Horas no Upstream não pode ficar em branco', 'Horas no Downstream não pode ficar em branco', 'Horas em Bugs não pode ficar em branco', 'Bugs Fechados não pode ficar em branco', 'Bugs Abertos não pode ficar em branco', 'Throughput não pode ficar em branco', 'Data não pode ficar em branco']
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
      let!(:project) { Fabricate :project, customer: customer, end_date: 5.days.from_now }
      let!(:project_result) { Fabricate :project_result, project: project }

      context 'passing valid IDs' do
        before { delete :destroy, params: { company_id: company, project_id: project, id: project_result } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_project_path(company, project)
          expect(ProjectResult.last).to be_nil
        end
      end
      context 'passing an invalid ID' do
        context 'non-existent project result' do
          before { delete :destroy, params: { company_id: company, project_id: project, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent project' do
          before { delete :destroy, params: { company_id: company, project_id: 'foo', id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', project_id: project, id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { delete :destroy, params: { company_id: company, project_id: project, id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let(:company) { Fabricate :company, users: [user] }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }
      let(:project_result) { Fabricate :project_result, project: project }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, project_id: project, id: project_result } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:project_result)).to eq project_result
        end
      end

      context 'invalid' do
        context 'project' do
          before { get :edit, params: { company_id: company, project_id: 'foo', id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'project_result' do
          before { get :edit, params: { company_id: company, project_id: project, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', project_id: project, id: project_result } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { get :edit, params: { company_id: company, project_id: project, id: project_result } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:company) { Fabricate :company, users: [user] }

      let(:team) { Fabricate :team, company: company }
      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }
      let(:project_result) { Fabricate :project_result, project: project }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, project_id: project, id: project_result, project_result: { team: team.id, result_date: Time.zone.today, known_scope: 100, qty_hours_upstream: 10, qty_hours_downstream: 13, throughput: 5, monte_carlo_date: 1.month.from_now, qty_bugs_opened: 0, qty_bugs_closed: 3, qty_hours_bug: 7, leadtime: 10.5 } } }
        it 'updates the project_result and redirects to projects index' do
          result = ProjectResult.last
          expect(result.team).to eq team
          expect(result.project).to eq project
          expect(result.result_date).to eq Time.zone.today
          expect(result.qty_hours_upstream).to eq 10
          expect(result.qty_hours_downstream).to eq 13
          expect(result.throughput).to eq 5
          expect(result.monte_carlo_date).to eq 1.month.from_now.to_date
          expect(result.qty_bugs_opened).to eq 0
          expect(result.qty_bugs_closed).to eq 3
          expect(result.qty_hours_bug).to eq 7
          expect(result.leadtime).to eq 10.5
          expect(result.flow_pressure.to_f).to be_within(0.01).of(1.61)
          expect(result.remaining_days).to eq 59
          expect(response).to redirect_to company_project_path(company, project)
        end
      end

      context 'passing invalid' do
        context 'project_result parameters' do
          before { put :update, params: { company_id: company, project_id: project, id: project_result, project_result: { name: '' } } }
          it 'does not update the project_result and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:project_result).errors.full_messages).to match_array ['Time não pode ficar em branco']
          end
        end
        context 'non-existent project_result' do
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, project_id: project, id: 'foo', project_result: { customer_id: customer, name: 'foo' } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, project_id: project, id: project_result, project_result: { customer_id: customer, name: 'foo' } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #show' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }
      let!(:project) { Fabricate :project, customer: product.customer, product: product, end_date: 5.days.from_now }
      let!(:project_result) { Fabricate :project_result, project: project }
      let!(:first_demand) { Fabricate :demand, project_result: project_result, demand_id: 'ZZZ' }
      let!(:second_demand) { Fabricate :demand, project_result: project_result, demand_id: 'AAA' }

      context 'passing a valid ID' do
        context 'having data' do
          before { get :show, params: { company_id: company, project_id: project, id: project_result } }
          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:project)).to eq project
            expect(assigns(:project_result)).to eq project_result
            expect(assigns(:demands)).to eq [second_demand, first_demand]
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
            expect(assigns(:demands)).to eq []
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
