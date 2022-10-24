# frozen_string_literal: true

RSpec.describe PortfolioUnitsController do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', product_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', product_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'bar', product_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'bar', product_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'bar', product_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'bar', product_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer }

    describe 'GET #new' do
      let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'zzz' }
      let!(:other_portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'aaa' }

      let!(:out_portfolio_unit) { Fabricate :portfolio_unit, name: 'aaa' }

      context 'with valid data' do
        it 'assigns the instance variables and render the template' do
          get :new, params: { company_id: company, product_id: product }, xhr: true
          expect(assigns(:company)).to eq company
          expect(assigns(:product)).to eq product
          expect(assigns(:portfolio_unit)).to be_a_new PortfolioUnit
          expect(assigns(:portfolio_units)).to eq [other_portfolio_unit, portfolio_unit]
          expect(assigns(:parent_portfolio_units)).to eq [other_portfolio_unit, portfolio_unit]
          expect(response).to render_template 'portfolio_units/new'
        end
      end

      context 'with invalid' do
        context 'product' do
          before { get :new, params: { company_id: company, product_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product in other company' do
          let(:other_product) { Fabricate :product }

          before { get :new, params: { company_id: company, product_id: other_product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          before { get :new, params: { company_id: 'foo', product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:other_company) { Fabricate :company }

          before { get :new, params: { company_id: other_company, product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'zzz' }

      context 'with valid data' do
        it 'creates the portfolio unit and renders the template' do
          post :create, params: { company_id: company, product_id: product, portfolio_unit: { parent_id: portfolio_unit.id, name: 'bla', portfolio_unit_type: :product_module, jira_portfolio_unit_config_attributes: { jira_field_name: 'foo' } } }, xhr: true
          created_unit = PortfolioUnit.last
          expect(created_unit.name).to eq 'bla'
          expect(created_unit.product_module?).to be true
          expect(created_unit.parent).to eq portfolio_unit

          created_jira_config = Jira::JiraPortfolioUnitConfig.last
          expect(created_jira_config.jira_field_name).to eq 'foo'
          expect(assigns(:portfolio_units)).to eq [created_unit, portfolio_unit]
          expect(assigns(:parent_portfolio_units)).to eq [portfolio_unit]

          expect(response).to render_template 'portfolio_units/create'
        end
      end

      context 'with invalid' do
        context 'parameters' do
          it 'adds errors to the model and to flash' do
            post :create, params: { company_id: company, product_id: product, portfolio_unit: { name: '', portfolio_unit_type: nil, jira_portfolio_unit_config_attributes: { jira_field_name: '' } } }, xhr: true

            expect(assigns(:portfolio_unit).errors.full_messages).to eq ['Tipo da Unidade não pode ficar em branco', 'Nome não pode ficar em branco']
            expect(flash[:error]).to eq 'Tipo da Unidade não pode ficar em branco, Nome não pode ficar em branco'
          end
        end

        context 'product' do
          before { post :create, params: { company_id: company, product_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product in other company' do
          let(:other_product) { Fabricate :product }

          before { post :create, params: { company_id: company, product_id: other_product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          before { post :create, params: { company_id: 'foo', product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:other_company) { Fabricate :company }

          before { post :create, params: { company_id: other_company, product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product }

      context 'valid parameters' do
        before { delete :destroy, params: { company_id: company, product_id: product, id: portfolio_unit }, xhr: true }

        it 'deletes the portfolio unit' do
          expect(response).to render_template 'portfolio_units/destroy'
          expect(PortfolioUnit.last).to be_nil
        end
      end

      context 'invalid parameters' do
        context 'non-existent product jira config' do
          before { delete :destroy, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent product' do
          before { delete :destroy, params: { company_id: company, product_id: 'foo', id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', product_id: product, id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, product_id: product, id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #show' do
      context 'with valid data' do
        it 'assigns the instance variables and render the template' do
          portfolio_unit = Fabricate :portfolio_unit, product: product, name: 'zzz'

          Fabricate :portfolio_unit, name: 'aaa'

          demand = Fabricate :demand, portfolio_unit: portfolio_unit, commitment_date: 3.days.ago, end_date: 2.days.ago
          other_demand = Fabricate :demand, portfolio_unit: portfolio_unit, commitment_date: 3.days.ago, end_date: 1.day.ago

          get :show, params: { company_id: company, product_id: product, id: portfolio_unit }, xhr: true

          expect(assigns(:company)).to eq company
          expect(assigns(:product)).to eq product
          expect(assigns(:portfolio_unit)).to eq portfolio_unit
          expect(assigns(:demands)).to eq [other_demand, demand]
          expect(assigns(:demands_chart_adapter)).to be_a Highchart::DemandsChartsAdapter
          expect(response).to render_template 'portfolio_units/show'
        end
      end

      context 'with invalid' do
        context 'portfolio_unit' do
          before { get :show, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product' do
          let(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'zzz' }

          before { get :show, params: { company_id: company, product_id: 'foo', id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product in other company' do
          let(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'zzz' }

          let(:other_product) { Fabricate :product }

          before { get :show, params: { company_id: company, product_id: other_product, id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          let(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'zzz' }

          before { get :show, params: { company_id: 'foo', product_id: product, id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:other_company) { Fabricate :company }

          before { get :new, params: { company_id: other_company, product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'zzz' }
      let!(:other_portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'aaa' }

      let!(:out_portfolio_unit) { Fabricate :portfolio_unit, name: 'aaa' }

      context 'with valid data' do
        it 'assigns the instance variables and render the template' do
          get :edit, params: { company_id: company, product_id: product, id: portfolio_unit }, xhr: true
          expect(assigns(:company)).to eq company
          expect(assigns(:product)).to eq product
          expect(assigns(:portfolio_unit)).to eq portfolio_unit
          expect(assigns(:portfolio_units)).to eq [other_portfolio_unit, portfolio_unit]
          expect(assigns(:parent_portfolio_units)).to eq [other_portfolio_unit]
          expect(response).to render_template 'portfolio_units/edit'
        end
      end

      context 'with invalid' do
        context 'portfolio unit' do
          before { get :edit, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product' do
          before { get :edit, params: { company_id: company, product_id: 'foo', id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product in other company' do
          let(:other_product) { Fabricate :product }

          before { get :edit, params: { company_id: company, product_id: other_product, id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          before { get :edit, params: { company_id: 'foo', product_id: product, id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:other_company) { Fabricate :company }

          before { get :edit, params: { company_id: other_company, product_id: product, id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PUT #update' do
      let!(:parent_portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'aaa' }
      let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'zzz' }

      context 'with valid data' do
        it 'updates the portfolio unit and renders the template' do
          put :update, params: { company_id: company, product_id: product, id: portfolio_unit, portfolio_unit: { parent_id: parent_portfolio_unit.id, name: 'bla', portfolio_unit_type: :product_module, jira_portfolio_unit_config_attributes: { jira_field_name: 'foo' } } }, xhr: true
          updated_unit = PortfolioUnit.last
          expect(updated_unit.name).to eq 'bla'
          expect(updated_unit.product_module?).to be true
          expect(updated_unit.parent).to eq parent_portfolio_unit

          updated_jira_config = Jira::JiraPortfolioUnitConfig.last
          expect(updated_jira_config.jira_field_name).to eq 'foo'
          expect(assigns(:portfolio_units)).to eq [parent_portfolio_unit, portfolio_unit]
          expect(assigns(:parent_portfolio_units)).to be_nil

          expect(response).to render_template 'portfolio_units/update'
        end
      end

      context 'with invalid' do
        context 'parameters' do
          it 'adds errors to the model and to flash' do
            put :update, params: { company_id: company, product_id: product, id: portfolio_unit, portfolio_unit: { name: '', portfolio_unit_type: nil, jira_portfolio_unit_config_attributes: { jira_field_name: '' } } }, xhr: true

            expect(assigns(:portfolio_units)).to eq [parent_portfolio_unit, portfolio_unit]
            expect(assigns(:parent_portfolio_units)).to eq [parent_portfolio_unit]

            expect(assigns(:portfolio_unit).errors.full_messages).to eq ['Tipo da Unidade não pode ficar em branco', 'Nome não pode ficar em branco']
            expect(flash[:error]).to eq 'Tipo da Unidade não pode ficar em branco, Nome não pode ficar em branco'
          end
        end

        context 'portfolio unit' do
          before { put :update, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product' do
          before { put :update, params: { company_id: company, product_id: 'foo', id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product in other company' do
          let(:other_product) { Fabricate :product }

          before { put :update, params: { company_id: company, product_id: other_product, id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          before { put :update, params: { company_id: 'foo', product_id: product, id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:other_company) { Fabricate :company }

          before { put :update, params: { company_id: other_company, product_id: product, id: portfolio_unit }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
