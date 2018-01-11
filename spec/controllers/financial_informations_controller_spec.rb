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
            expect(assigns(:financial_information).errors.full_messages).to eq ['Data das Finanças não pode ficar em branco', 'Receitas totais não pode ficar em branco', 'Despesas totais não pode ficar em branco']
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
  end
end
