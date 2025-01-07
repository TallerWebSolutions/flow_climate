# frozen_string_literal: true

RSpec.describe ContractsController do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', customer_id: 'xpto' } }

      it { expect(response).to redirect_to new_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', customer_id: 'xpto' } }

      it { expect(response).to redirect_to new_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'bar', customer_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'bar', customer_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', customer_id: 'xpto', id: 'bar' } }

      it { expect(response).to redirect_to new_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'foo', customer_id: 'xpto', id: 'bar' } }

      it { expect(response).to redirect_to new_session_path }
    end

    describe 'GET #update_consolidations' do
      before { get :update_consolidations, params: { company_id: 'foo', customer_id: 'xpto', id: 'bar' } }

      it { expect(response).to redirect_to new_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { login_as user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer }

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
        it 'creates the new contract and redirects to its show' do
          expect(ContractService.instance).to(receive(:update_demands)).once
          post :create, params: { company_id: company, customer_id: customer, contract: { product_id: product.id, start_date: 2.days.ago, end_date: 3.days.from_now, total_hours: 10, total_value: 100, hours_per_demand: 30, renewal_period: :yearly, automatic_renewal: true } }

          created_contract = Contract.last

          expect(created_contract.product).to eq product
          expect(created_contract.start_date).to eq 2.days.ago.to_date
          expect(created_contract.end_date).to eq 3.days.from_now.to_date
          expect(created_contract.total_hours).to eq 10
          expect(created_contract.total_value).to eq 100
          expect(created_contract.hours_per_demand).to eq 30
          expect(created_contract.renewal_period).to eq 'yearly'
          expect(created_contract.automatic_renewal).to be true

          expect(ContractEstimationChangeHistory.count).to eq 1
          expect(ContractEstimationChangeHistory.last.change_date.to_date).to eq Time.zone.today
          expect(ContractEstimationChangeHistory.last.hours_per_demand).to eq 30

          expect(flash[:notice]).to eq I18n.t('contracts.create.success')
          expect(response).to redirect_to company_customer_path(company, customer)
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          it 'does not create the contract and re-render the template with the errors' do
            expect(ContractService.instance).not_to(receive(:update_demands))
            post :create, params: { company_id: company, customer_id: customer, contract: { product_id: nil, start_date: nil, end_date: nil, total_hours: nil, total_value: nil, renewal_period: nil, automatic_renewal: nil } }

            expect(Contract.last).to be_nil
            expect(response).to render_template :new
            expect(flash[:error]).to eq I18n.t('contracts.save.error')
            expect(assigns(:contract).errors.full_messages).to eq ['Produto deve existir', 'Início não pode ficar em branco', 'Horas Totais não pode ficar em branco', 'Valor Total não pode ficar em branco', 'Período de Renovação não pode ficar em branco']
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
      let!(:contract) { Fabricate :contract, customer: customer, hours_per_demand: 10 }

      context 'with valid parameters' do
        context 'with estimation change' do
          it 'updates the contract and redirects to company show and creates a new estimation change history' do
            expect(ContractService.instance).to(receive(:update_demands)).once
            put :update, params: { company_id: company, customer_id: customer, id: contract, contract: { product_id: product.id, start_date: 2.days.ago, end_date: 3.days.from_now, total_hours: 10, total_value: 100, hours_per_demand: 30, renewal_period: :yearly, automatic_renewal: true } }

            updated_contract = Contract.last
            expect(updated_contract.product).to eq product
            expect(updated_contract.start_date).to eq 2.days.ago.to_date
            expect(updated_contract.end_date).to eq 3.days.from_now.to_date
            expect(updated_contract.total_hours).to eq 10
            expect(updated_contract.total_value).to eq 100
            expect(updated_contract.hours_per_demand).to eq 30
            expect(updated_contract.renewal_period).to eq 'yearly'
            expect(updated_contract.automatic_renewal).to be true

            expect(ContractEstimationChangeHistory.count).to eq 2
            expect(ContractEstimationChangeHistory.last.change_date.to_date).to eq Time.zone.today
            expect(ContractEstimationChangeHistory.last.hours_per_demand).to eq 30

            expect(flash[:notice]).to eq I18n.t('contracts.update.success')
            expect(response).to redirect_to company_customer_path(company, customer)
          end
        end

        context 'with no estimation change' do
          it 'updates the contract and redirects to company show and does not create a new estimation change history' do
            expect(ContractService.instance).to(receive(:update_demands)).once
            put :update, params: { company_id: company, customer_id: customer, id: contract, contract: { product_id: product.id, start_date: 2.days.ago, end_date: 3.days.from_now, total_hours: 10, total_value: 100, hours_per_demand: 10, renewal_period: :yearly, automatic_renewal: true } }

            updated_contract = Contract.last
            expect(updated_contract.product).to eq product
            expect(updated_contract.start_date).to eq 2.days.ago.to_date
            expect(updated_contract.end_date).to eq 3.days.from_now.to_date
            expect(updated_contract.total_hours).to eq 10
            expect(updated_contract.total_value).to eq 100
            expect(updated_contract.hours_per_demand).to eq 10
            expect(updated_contract.renewal_period).to eq 'yearly'
            expect(updated_contract.automatic_renewal).to be true

            expect(ContractEstimationChangeHistory.count).to eq 1
            expect(ContractEstimationChangeHistory.last.change_date.to_date).to eq Time.zone.today
            expect(ContractEstimationChangeHistory.last.hours_per_demand).to eq 10

            expect(flash[:notice]).to eq I18n.t('contracts.update.success')
            expect(response).to redirect_to company_customer_path(company, customer)
          end
        end
      end

      context 'passing invalid' do
        context 'contract parameters' do
          it 'does not update the contract and re-render the template with the errors' do
            expect(ContractService.instance).not_to(receive(:update_demands))
            put :update, params: { company_id: company, customer_id: customer, id: contract, contract: { product_id: nil, start_date: nil, end_date: nil, total_hours: nil, total_value: nil, renewal_period: nil, automatic_renewal: nil } }

            expect(response).to render_template :edit
            expect(flash[:error]).to eq I18n.t('contracts.save.error')
            expect(assigns(:contract).errors.full_messages).to eq ['Produto deve existir', 'Início não pode ficar em branco', 'Horas Totais não pode ficar em branco', 'Valor Total não pode ficar em branco', 'Período de Renovação não pode ficar em branco']
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
            contracts_info = instance_double(Flow::ContractsFlowInformation,
                                             contract: contract, delivered_demands_count: 2, remaining_backlog_count: 4, consumed_hours: 1,
                                             remaining_hours: 5, dates_array: [1.day.ago, Time.zone.now], dates_limit_now_array: [1.day.ago, Time.zone.now],
                                             build_financial_burnup: { name: 'bla', data: [1, 2] }, build_hours_burnup: { name: 'bla', data: [1, 2] },
                                             build_scope_burnup: { name: 'bla', data: [1, 2] }, build_quality_info: { name: 'bla', data: [1, 2] },
                                             build_lead_time_info: { name: 'bla', data: [1, 2] }, build_throughput_info: { name: 'bla', data: [1, 2] },
                                             build_risk_info: { name: 'bla', risk_info: [2.4, 20.5] },
                                             build_hours_blocked_per_delivery_info: { name: 'bla', data: [2, 3.2] },
                                             build_external_dependency_info: { name: 'bla', data: [2, 3.2] },
                                             build_effort_info: { name: 'bla', data: [2, 3.2] })

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

    describe 'PATCH #update_consolidations' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:contract) { Fabricate :contract, customer: customer }

      context 'passing valid parameters' do
        it 'calls the consolidation job and notices the user' do
          expect(Consolidations::ContractConsolidationJob).to(receive(:perform_later)).once

          patch :update_consolidations, params: { company_id: company, customer_id: customer, id: contract }

          expect(response).to redirect_to company_customer_path(company, customer)
          expect(flash[:notice]).to eq I18n.t('general.enqueued')
        end
      end

      context 'passing an invalid' do
        context 'non-existent contract' do
          before { patch :update_consolidations, params: { company_id: company, customer_id: customer, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent customer' do
          before { patch :update_consolidations, params: { company_id: company, customer_id: 'foo', id: contract } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :update_consolidations, params: { company_id: 'foo', customer_id: customer, id: contract } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :update_consolidations, params: { company_id: company, customer_id: customer, id: contract } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
