# frozen_string_literal: true

RSpec.describe CustomersController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }

    describe 'GET #index' do
      let(:customer) { Fabricate :customer, company: company, name: 'zzz' }
      let!(:project) { Fabricate :project, customers: [customer], start_date: Time.zone.today, end_date: 2.days.from_now, initial_scope: 100 }

      context 'passing valid parameters' do
        context 'valid parameters' do
          let(:other_customer) { Fabricate :customer, company: company, name: 'aaa' }
          let!(:other_project) { Fabricate :project, customers: [other_customer], start_date: Time.zone.today, end_date: 1.day.from_now, initial_scope: 200 }

          let(:out_customer) { Fabricate :customer, name: 'aaa' }

          before { get :index, params: { company_id: company } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :index
            expect(assigns(:customers)).to eq [other_customer, customer]
          end
        end
      end

      context 'passing invalid parameters' do
        context 'non-existent company' do
          before { get :index, params: { company_id: 'foo', id: customer } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { get :index, params: { company_id: company } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company } }

        it 'instantiates a new Customer and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:customer)).to be_a_new Customer
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, customer: { name: 'foo' } } }

        it 'creates the new customer and redirects to its show' do
          expect(Customer.last.name).to eq 'foo'
          expect(response).to redirect_to company_customers_path(company)
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          before { post :create, params: { company_id: company, customer: { name: '' } } }

          it 'does not create the customer and re-render the template with the errors' do
            expect(Customer.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:customer).errors.full_messages).to eq ['Nome não pode ficar em branco']
          end
        end

        context 'company' do
          context 'non-existent' do
            before { post :create, params: { company_id: 'bar', customer: { name: 'foo' } } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { post :create, params: { company_id: company, customer: { name: 'foo' } } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #edit' do
      let(:customer) { Fabricate :customer, company: company }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, id: customer } }

        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:customer)).to eq customer
        end
      end

      context 'invalid' do
        context 'customer' do
          before { get :edit, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', id: customer } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :edit, params: { company_id: company, id: customer } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:customer) { Fabricate :customer, company: company }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, id: customer, customer: { name: 'foo' } } }

        it 'updates the customer and redirects to company show' do
          expect(Customer.last.name).to eq 'foo'
          expect(response).to redirect_to company_customers_path(company)
        end
      end

      context 'passing invalid' do
        context 'customer parameters' do
          before { put :update, params: { company_id: company, id: customer, customer: { name: nil } } }

          it 'does not update the customer and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:customer).errors.full_messages).to eq ['Nome não pode ficar em branco']
          end
        end

        context 'non-existent customer' do
          before { put :update, params: { company_id: company, id: 'foo', customer: { name: 'foo' } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { put :update, params: { company_id: company, id: customer, customer: { name: 'foo' } } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #show' do
      let(:customer) { Fabricate :customer, company: company }

      context 'passing a valid ID' do
        context 'having projects' do
          let!(:first_project) { Fabricate :project, customers: [customer], end_date: 5.days.from_now }
          let!(:second_project) { Fabricate :project, customers: [customer], end_date: 7.days.from_now }

          before { get :show, params: { company_id: company, id: customer } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:customer)).to eq customer
            expect(assigns(:customer_projects)).to eq [second_project, first_project]
          end
        end

        context 'having no projects' do
          before { get :show, params: { company_id: company, id: customer.id } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:company)).to eq company
            expect(assigns(:customer)).to eq customer
            expect(assigns(:customer_projects)).to eq []
          end
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { get :show, params: { company_id: 'foo', id: customer } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'customer' do
          before { get :show, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :show, params: { company_id: company, id: customer } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, id: customer } }

          it 'deletes the customer and redirects' do
            expect(response).to redirect_to company_customers_path(company)
            expect(Customer.last).to be_nil
          end
        end

        context 'having dependencies' do
          let!(:product) { Fabricate :product, customer: customer }

          before { delete :destroy, params: { company_id: company, id: customer } }

          it 'does not delete the customer and show the error' do
            expect(response).to redirect_to company_customers_path(company)
            expect(Customer.last).to eq customer
            expect(flash[:error]).to eq assigns(:customer).errors.full_messages.join(',')
          end
        end
      end

      context 'passing invalid' do
        context 'customer' do
          before { delete :destroy, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { delete :destroy, params: { company_id: 'foo', id: customer } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { delete :destroy, params: { company_id: company, id: customer } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
