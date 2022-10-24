# frozen_string_literal: true

RSpec.describe TasksController do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #charts' do
      before { get :charts, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }

    before { sign_in user }

    describe 'GET #show' do
      context 'with valid params' do
        context 'with data' do
          it 'assigns the instance variables and renders the template' do
            demand = Fabricate :demand, company: company
            task = Fabricate :task, demand: demand, created_date: 1.day.ago

            get :show, params: { company_id: company, id: task }

            expect(assigns(:task)).to eq task
            expect(response).to render_template :show
          end
        end
      end

      context 'with invalid params' do
        context 'task' do
          before { get :show, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          let(:demand) { Fabricate :demand }
          let(:task) { Fabricate :task }

          context 'not found' do
            before { get :show, params: { company_id: 'foo', id: task } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            before { get :show, params: { company_id: demand.company, id: task } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #index' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, company: company }
      let(:demand) { Fabricate :demand, company: company, project: project }

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          get :index, params: { company_id: company }, xhr: true

          expect(response).to render_template 'spa-build/index'
        end
      end

      context 'passing an invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :index, params: { company_id: 'foo', id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :index, params: { company_id: company, id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #charts' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, company: company }
      let(:demand) { Fabricate :demand, company: company, project: project }

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          get :charts, params: { company_id: company }, xhr: true

          expect(response).to render_template 'spa-build/index'
        end
      end

      context 'passing an invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :charts, params: { company_id: 'foo', id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :charts, params: { company_id: company, id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
