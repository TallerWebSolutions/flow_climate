# frozen_string_literal: true

RSpec.describe OperationResultsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'GET #index' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:result) { Fabricate :operation_result, company: company, result_date: 2.days.ago }
      let!(:other_result) { Fabricate :operation_result, company: company, result_date: Time.zone.today }

      context 'with valid parameters' do
        before { get :index, params: { company_id: company } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template :index
          expect(assigns(:operation_results)).to eq [other_result, result]
        end
      end

      context 'with invalid parameters' do
        context 'and invalid company' do
          before { get :index, params: { company_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:operation_result) { Fabricate :operation_result, company: company }

      context 'passing valid IDs' do
        before { delete :destroy, params: { company_id: company, id: operation_result } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_operation_results_path(company)
          expect(OperationResult.last).to be_nil
        end
      end
      context 'passing an invalid ID' do
        context 'non-existent operation result' do
          before { delete :destroy, params: { company_id: company, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', id: operation_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { delete :destroy, params: { company_id: company, id: operation_result } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #new' do
      let(:company) { Fabricate :company, users: [user] }

      context 'passing valid IDs' do
        before { get :new, params: { company_id: company } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:operation_result)).to be_a_new OperationResult
          expect(assigns(:operation_result).company).to eq company
        end
      end
      context 'passing an invalid ID' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { get :new, params: { company_id: company } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      let(:company) { Fabricate :company, users: [user] }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, operation_result: { result_date: Time.zone.today, people_billable_count: 11, operation_week_value: 2003.21, available_hours: 222, delivered_hours: 222, total_th: 9, total_opened_bugs: 0, total_accumulated_closed_bugs: 1 } } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_operation_results_path(company)
          result = OperationResult.last
          expect(result.company).to eq company
          expect(result.people_billable_count).to eq 11
          expect(result.operation_week_value).to eq 2003.21
          expect(result.available_hours).to eq 222
          expect(result.delivered_hours).to eq 222
          expect(result.total_th).to eq 9
          expect(result.total_opened_bugs).to eq 0
          expect(result.total_accumulated_closed_bugs).to eq 1
        end
      end
      context 'passing invalid' do
        context 'company' do
          before { post :create, params: { company_id: 'foo', operation_result: { result_date: Time.zone.today, qty_hours_upstream: 10, qty_hours_downstream: 13, throughput: 5, qty_bugs_opened: 0, qty_bugs_closed: 3, qty_hours_bug: 7, leadtime: 10.5 } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'results parameters' do
          before { post :create, params: { company_id: company, operation_result: { result_date: nil, people_billable_count: nil, operation_week_value: nil, available_hours: nil, delivered_hours: nil, total_th: nil, total_opened_bugs: nil, total_accumulated_closed_bugs: nil } } }
          it 'renders the template again showing the errors' do
            expect(response).to render_template :new
            expect(assigns(:operation_result).errors.full_messages).to eq ['Data não pode ficar em branco', 'Qtd de Pessoas Faturáveis não pode ficar em branco', 'Valor da Operação na Semana não pode ficar em branco', 'Horas Disponíveis não pode ficar em branco', 'Horas Consumidas não pode ficar em branco', 'Throughput Total não pode ficar em branco', 'Bugs Abertos não pode ficar em branco', 'Acumulado de Bugs Fechados não pode ficar em branco']
          end
        end
      end
    end
  end
end
