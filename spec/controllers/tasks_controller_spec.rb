# frozen_string_literal: true

RSpec.describe TasksController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #search' do
      before { post :search, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #charts' do
      before { post :charts, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }

    before { sign_in user }

    describe 'GET #index' do
      context 'with valid params' do
        context 'with data' do
          it 'assigns the instance variables and renders the template' do
            demand = Fabricate :demand, company: company
            discarded_demand = Fabricate :demand, company: company, discarded_at: 2.days.ago
            task = Fabricate :task, demand: demand, created_date: 1.day.ago
            other_task = Fabricate :task, demand: demand, created_date: Time.zone.now
            Fabricate :task, demand: discarded_demand, created_date: Time.zone.now

            get :index, params: { company_id: company }

            expect(assigns(:tasks)).to eq [other_task, task]
            expect(response).to render_template :index
          end
        end

        context 'with no data' do
          it 'assigns an empty variable and renders the template' do
            get :index, params: { company_id: company }

            expect(assigns(:tasks)).to eq []
            expect(response).to render_template :index
          end
        end
      end

      context 'with invalid params' do
        context 'company' do
          let(:demand) { Fabricate :demand }

          context 'not found' do
            before { get :index, params: { company_id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            before { get :index, params: { company_id: demand.company } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'POST #search' do
      context 'with valid params' do
        context 'with search' do
          it 'assigns the instance variables and renders the template' do
            demand = Fabricate :demand, company: company
            discarded_demand = Fabricate :demand, company: company, discarded_at: 2.days.ago
            task = Fabricate :task, demand: demand, created_date: 2.days.ago, end_date: 1.day.ago, title: 'fOo'
            other_task = Fabricate :task, demand: demand, created_date: 1.day.ago, end_date: 1.hour.ago, title: 'fOObar'
            Fabricate :task, demand: discarded_demand, created_date: 1.day.ago, end_date: 1.hour.ago, title: 'fOObar'
            Fabricate :task, demand: demand, created_date: 1.day.ago, end_date: nil, title: 'barfOO'
            Fabricate :task, demand: demand, created_date: 2.hours.ago, end_date: 1.hour.ago, title: 'xpto'

            post :search, params: { company_id: company, tasks_search: 'foo', task_status: 'finished' }

            expect(assigns(:tasks)).to eq [other_task, task]
            expect(response).to render_template :index
          end
        end

        context 'with no search' do
          it 'assigns the instance variables and renders the template' do
            demand = Fabricate :demand, company: company
            task = Fabricate :task, demand: demand, created_date: 2.days.ago, title: 'fOo'
            other_task = Fabricate :task, demand: demand, created_date: 1.day.ago, title: 'fOObar'
            another_task = Fabricate :task, demand: demand, created_date: Time.zone.now, title: 'xpto'

            post :search, params: { company_id: company }

            expect(assigns(:tasks)).to eq [another_task, other_task, task]
            expect(response).to render_template :index
          end
        end

        context 'with no data' do
          it 'assigns an empty variable and renders the template' do
            post :search, params: { company_id: company, tasks_search: 'foo' }

            expect(assigns(:tasks)).to eq []
            expect(response).to render_template :index
          end
        end
      end

      context 'with invalid params' do
        context 'company' do
          let(:demand) { Fabricate :demand }

          context 'not found' do
            before { post :search, params: { company_id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            before { post :search, params: { company_id: demand.company } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'POST #charts' do
      context 'with valid params' do
        context 'with search' do
          it 'assigns the instance variables and renders the template' do
            demand = Fabricate :demand, company: company
            task = Fabricate :task, demand: demand, created_date: 2.days.ago, end_date: Time.zone.now, title: 'fOo'
            other_task = Fabricate :task, demand: demand, created_date: 1.day.ago, end_date: 2.hours.ago, title: 'fOObar'
            Fabricate :task, demand: demand, created_date: Time.zone.now, title: 'xpto'

            post :charts, params: { company_id: company, tasks_search: 'foo' }

            expect(assigns(:tasks)).to eq [other_task, task]
            expect(assigns(:task_completion_control_chart_data).pluck(:id)).to eq [other_task.external_id, task.external_id]
            expect(assigns(:task_completion_control_chart_data).pluck(:completion_time)).to eq [other_task.seconds_to_complete, task.seconds_to_complete]

            expect(response).to render_template :charts
          end
        end

        context 'with no search' do
          it 'assigns the chart variable with the finished tasks and renders the template' do
            demand = Fabricate :demand, company: company
            task = Fabricate :task, demand: demand, created_date: 2.days.ago, end_date: Time.zone.now, title: 'fOo'
            other_task = Fabricate :task, demand: demand, created_date: 1.day.ago, end_date: 2.hours.ago, title: 'fOObar'
            another_task = Fabricate :task, demand: demand, created_date: Time.zone.now, title: 'xpto'

            post :charts, params: { company_id: company }

            expect(assigns(:tasks)).to eq [another_task, other_task, task]
            expect(assigns(:task_completion_control_chart_data).pluck(:id)).to eq [other_task.external_id, task.external_id]
            expect(assigns(:task_completion_control_chart_data).pluck(:completion_time)).to eq [other_task.seconds_to_complete, task.seconds_to_complete]

            expect(response).to render_template :charts
          end
        end

        context 'with no data' do
          it 'assigns an empty variable and renders the template' do
            post :charts, params: { company_id: company, tasks_search: 'foo' }

            expect(assigns(:tasks)).to eq []
            expect(response).to render_template :charts
          end
        end
      end

      context 'with invalid params' do
        context 'company' do
          let(:demand) { Fabricate :demand }

          context 'not found' do
            before { post :charts, params: { company_id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            before { post :charts, params: { company_id: demand.company } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

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
  end
end