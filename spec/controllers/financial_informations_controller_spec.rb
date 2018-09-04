# frozen_string_literal: true

RSpec.describe FinancialInformationsController, type: :controller do
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
      before { get :edit, params: { company_id: 'xpto', id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', id: 'foo' } }
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
          expect(assigns(:financial_information)).to be_a_new FinancialInformation
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
        before { post :create, params: { company_id: company, financial_information: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
        it 'creates the new financial information to the company and redirects to its show' do
          expect(FinancialInformation.last.company).to eq company
          expect(FinancialInformation.last.finances_date).to eq Time.zone.today
          expect(FinancialInformation.last.income_total).to eq 10
          expect(FinancialInformation.last.expenses_total).to eq 5
          expect(response).to redirect_to company_path(Company.last)
        end
      end
      context 'passing invalid parameters' do
        context 'invalid attributes' do
          before { post :create, params: { company_id: company, financial_information: { finances: nil, income_total: nil, expenses_total: nil } } }
          it 'does not create the company and re-render the template with the errors' do
            expect(FinancialInformation.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:financial_information).errors.full_messages).to eq ['Data das Finanças não pode ficar em branco', 'Entradas totais não pode ficar em branco', 'Saídas totais não pode ficar em branco']
          end
        end
        context 'inexistent company' do
          before { post :create, params: { company_id: 'foo', financial_information: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted company' do
          let(:company) { Fabricate :company }
          before { post :create, params: { company_id: company, financial_information: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let(:customer) { Fabricate :customer, company: company }
      let(:financial_information) { Fabricate :financial_information, company: company }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, id: financial_information } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:financial_information)).to eq financial_information
        end
      end

      context 'invalid' do
        context 'financial_information' do
          before { get :edit, params: { company_id: company, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', id: financial_information } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { get :edit, params: { company_id: company, id: financial_information } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:customer) { Fabricate :customer, company: company }
      let(:financial_information) { Fabricate :financial_information, company: company }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, id: financial_information, financial_information: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
        it 'updates the financial_information and redirects to projects index' do
          expect(FinancialInformation.last.finances_date).to eq Time.zone.today
          expect(FinancialInformation.last.income_total).to eq 10
          expect(FinancialInformation.last.expenses_total).to eq 5
          expect(response).to redirect_to company_path(company)
        end
      end

      context 'passing invalid' do
        context 'financial_information parameters' do
          before { put :update, params: { company_id: company, id: financial_information, financial_information: { finances_date: nil, income_total: nil, expenses_total: nil } } }
          it 'does not update the financial_information and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:financial_information).errors.full_messages).to match_array ['Data das Finanças não pode ficar em branco', 'Entradas totais não pode ficar em branco', 'Saídas totais não pode ficar em branco']
          end
        end
        context 'non-existent financial_information' do
          before { put :update, params: { company_id: company, id: 'foo', financial_information: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { put :update, params: { company_id: company, id: financial_information, financial_information: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:financial_information) { Fabricate :financial_information, company: company }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, id: financial_information } }
          it 'deletes the financial_information and redirects' do
            expect(response).to redirect_to company_path(company)
            expect(FinancialInformation.last).to be_nil
          end
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent financial_information' do
          before { delete :destroy, params: { company_id: company, id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', id: financial_information } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { delete :destroy, params: { company_id: company, id: financial_information } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
