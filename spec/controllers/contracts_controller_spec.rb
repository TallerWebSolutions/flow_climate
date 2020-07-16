# frozen_string_literal: true

RSpec.describe ContractsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', customer_id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', customer_id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'bar', customer_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'bar', customer_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', customer_id: 'xpto', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'foo', customer_id: 'xpto', id: 'bar' } }

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
    let(:product) { Fabricate :product, customer: customer }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, customer_id: customer } }

        it 'instantiates a new Contract and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:contract)).to be_a_new Contract
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo', customer_id: customer } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company, customer_id: customer } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, customer_id: customer, contract: { product_id: product.id, start_date: 2.days.ago, end_date: 3.days.from_now, total_hours: 10, total_value: 100, hours_per_demand: 30, renewal_period: :yearly, automatic_renewal: true } } }

        it 'creates the new contract and redirects to its show' do
          created_contract = Contract.last

          expect(created_contract.product).to eq product
          expect(created_contract.start_date).to eq 2.days.ago.to_date
          expect(created_contract.end_date).to eq 3.days.from_now.to_date
          expect(created_contract.total_hours).to eq 10
          expect(created_contract.total_value).to eq 100
          expect(created_contract.hours_per_demand).to eq 30
          expect(created_contract.renewal_period).to eq 'yearly'
          expect(created_contract.automatic_renewal).to eq true

          expect(flash[:notice]).to eq I18n.t('contracts.create.success')
          expect(response).to redirect_to company_customer_path(company, customer)
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          before { post :create, params: { company_id: company, customer_id: customer, contract: { product_id: nil, start_date: nil, end_date: nil, total_hours: nil, total_value: nil, renewal_period: nil, automatic_renewal: nil } } }

          it 'does not create the contract and re-render the template with the errors' do
            expect(Contract.last).to be_nil
            expect(response).to render_template :new
            expect(flash[:error]).to eq I18n.t('contracts.save.error')
            expect(assigns(:contract).errors.full_messages).to eq ['Produto não pode ficar em branco', 'Início não pode ficar em branco', 'Horas Totais não pode ficar em branco', 'Valor Total não pode ficar em branco', 'Período de Renovação não pode ficar em branco']
          end
        end

        context 'company' do
          context 'non-existent' do
            before { post :create, params: { company_id: 'bar', customer_id: customer, contract: { product_id: product.id, start_date: 2.days.ago, end_date: 3.days.from_now, total_hours: 10, total_value: 100, renewal_period: :yearly, automatic_renewal: true } } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { post :create, params: { company_id: company, customer_id: customer, contract: { product_id: product.id, start_date: 2.days.ago, end_date: 3.days.from_now, total_hours: 10, total_value: 100, renewal_period: :yearly, automatic_renewal: true } } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #edit' do
      let(:contract) { Fabricate :contract, customer: customer }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, customer_id: customer, id: contract } }

        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:contract)).to eq contract
        end
      end

      context 'invalid' do
        context 'contract' do
          before { get :edit, params: { company_id: company, customer_id: customer, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', customer_id: customer, id: contract } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :edit, params: { company_id: company, customer_id: customer, id: contract } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:contract) { Fabricate :contract, customer: customer }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, customer_id: customer, id: contract, contract: { product_id: product.id, start_date: 2.days.ago, end_date: 3.days.from_now, total_hours: 10, total_value: 100, hours_per_demand: 30, renewal_period: :yearly, automatic_renewal: true } } }

        it 'updates the contract and redirects to company show' do
          updated_contract = Contract.last
          expect(updated_contract.product).to eq product
          expect(updated_contract.start_date).to eq 2.days.ago.to_date
          expect(updated_contract.end_date).to eq 3.days.from_now.to_date
          expect(updated_contract.total_hours).to eq 10
          expect(updated_contract.total_value).to eq 100
          expect(updated_contract.hours_per_demand).to eq 30
          expect(updated_contract.renewal_period).to eq 'yearly'
          expect(updated_contract.automatic_renewal).to eq true

          expect(flash[:notice]).to eq I18n.t('contracts.update.success')
          expect(response).to redirect_to company_customer_path(company, customer)
        end
      end

      context 'passing invalid' do
        context 'contract parameters' do
          before { put :update, params: { company_id: company, customer_id: customer, id: contract, contract: { product_id: nil, start_date: nil, end_date: nil, total_hours: nil, total_value: nil, renewal_period: nil, automatic_renewal: nil } } }

          it 'does not update the contract and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(flash[:error]).to eq I18n.t('contracts.save.error')
            expect(assigns(:contract).errors.full_messages).to eq ['Produto não pode ficar em branco', 'Início não pode ficar em branco', 'Horas Totais não pode ficar em branco', 'Valor Total não pode ficar em branco', 'Período de Renovação não pode ficar em branco']
          end
        end

        context 'non-existent contract' do
          before { put :update, params: { company_id: company, id: 'foo', customer_id: customer, contract: { product_id: product.id, start_date: 2.days.ago, end_date: 3.days.from_now, total_hours: 10, total_value: 100, renewal_period: :yearly, automatic_renewal: true } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { put :update, params: { company_id: company, customer_id: customer, id: contract, contract: { product_id: product.id, start_date: 2.days.ago, end_date: 3.days.from_now, total_hours: 10, total_value: 100, renewal_period: :yearly, automatic_renewal: true } } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:contract) { Fabricate :contract, customer: customer }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, customer_id: customer, id: contract } }

          it 'deletes the contract and redirects' do
            expect(response).to redirect_to company_customer_path(company, customer)
            expect(Contract.last).to be_nil
          end
        end
      end

      context 'passing invalid' do
        context 'contract' do
          before { delete :destroy, params: { company_id: company, customer_id: customer, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { delete :destroy, params: { company_id: 'foo', customer_id: customer, id: contract } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { delete :destroy, params: { company_id: company, customer_id: customer, id: contract } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #show' do
      let(:company) { Fabricate :company, users: [user] }
      let(:contract) { Fabricate :contract, customer: customer }
      let!(:contract_consolidation) { Fabricate :contract_consolidation, contract: contract, consolidation_date: Time.zone.today }
      let!(:other_contract_consolidation) { Fabricate :contract_consolidation, contract: contract, consolidation_date: 1.week.ago }

      context 'passing valid ID' do
        context 'having no dependencies' do
          it 'assigns the instance variables and renders the template' do
            contracts_info = instance_double('Flow::ContractsFlowInformation',
                                             contract: contract, delivered_demands_count: 2, remaining_backlog_count: 4, consumed_hours: 1,
                                             remaining_hours: 5, dates_array: [1.day.ago, Time.zone.now], dates_limit_now_array: [1.day.ago, Time.zone.now],
                                             build_financial_burnup: { name: 'bla', data: [1, 2] }, build_hours_burnup: { name: 'bla', data: [1, 2] },
                                             build_scope_burnup: { name: 'bla', data: [1, 2] }, build_quality_info: { name: 'bla', data: [1, 2] },
                                             build_lead_time_info: { name: 'bla', data: [1, 2] }, build_throughput_info: { name: 'bla', data: [1, 2] },
                                             build_risk_info: { name: 'bla', risk_info: [2.4, 20.5] })

            expect(Flow::ContractsFlowInformation).to receive(:new).once.and_return(contracts_info)

            get :show, params: { company_id: company, customer_id: customer, id: contract }
            expect(response).to render_template :show
            expect(assigns(:contract)).to eq contract
          end
        end
      end

      context 'passing invalid' do
        context 'contract' do
          before { get :show, params: { company_id: company, customer_id: customer, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :show, params: { company_id: 'foo', customer_id: customer, id: contract } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :show, params: { company_id: company, customer_id: customer, id: contract } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
