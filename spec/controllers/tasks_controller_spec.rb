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
            travel_to Time.zone.local(2022, 2, 16, 10, 0, 0) do
              demand = Fabricate :demand, company: company
              discarded_demand = Fabricate :demand, company: company, discarded_at: 2.days.ago
              task = Fabricate :task, demand: demand, created_date: 1.day.ago
              other_task = Fabricate :task, demand: demand, created_date: Time.zone.now, end_date: Time.zone.now
              Fabricate :task, demand: discarded_demand, created_date: Time.zone.now

              get :index, params: { company_id: company }

              expect(assigns(:tasks)).to eq [other_task, task]
              expect(assigns(:finished_tasks)).to eq [other_task]
              expect(response).to render_template :index
            end
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
        context 'with search by status and text' do
          it 'assigns the instance variables and renders the template according to the search' do
            travel_to Time.zone.local(2022, 2, 16, 10, 0, 0) do
              demand = Fabricate :demand, company: company
              discarded_demand = Fabricate :demand, company: company, discarded_at: 2.days.ago
              task = Fabricate :task, demand: demand, created_date: 2.days.ago, end_date: 1.day.ago, title: 'fOo'
              other_task = Fabricate :task, demand: demand, created_date: 1.day.ago, end_date: 1.hour.ago, title: 'fOObar'
              Fabricate :task, demand: discarded_demand, created_date: 1.day.ago, end_date: 1.hour.ago, title: 'fOObar'
              Fabricate :task, demand: demand, created_date: 1.day.ago, end_date: nil, title: 'barfOO'
              Fabricate :task, demand: demand, created_date: 2.hours.ago, end_date: 1.hour.ago, title: 'xpto'

              post :search, params: { company_id: company, tasks_search: 'foo', task_status: 'finished' }

              expect(assigns(:tasks)).to eq [other_task, task]
              expect(assigns(:tasks)).to eq [other_task, task]
              expect(response).to render_template :index
            end
          end
        end

        context 'with search by tasks dates without status search' do
          it 'searches by created date and renders the template' do
            travel_to Time.zone.local(2022, 2, 16, 10, 0, 0) do
              demand = Fabricate :demand, company: company
              discarded_demand = Fabricate :demand, company: company, discarded_at: 2.days.ago
              task = Fabricate :task, demand: demand, created_date: 2.days.ago, end_date: 1.day.ago
              other_task = Fabricate :task, demand: demand, created_date: 1.day.ago, end_date: 1.hour.ago
              Fabricate :task, demand: discarded_demand, created_date: 1.day.ago, end_date: 1.hour.ago
              Fabricate :task, demand: demand, created_date: 3.days.ago, end_date: nil

              post :search, params: { company_id: company, tasks_start_date: 52.hours.ago.to_date, tasks_end_date: 1.minute.ago.to_date, task_status: 'foo' }

              expect(assigns(:tasks)).to eq [other_task, task]
              expect(response).to render_template :index
            end
          end
        end

        context 'with search by tasks dates with status search, but opened' do
          it 'searches by created date and renders the template' do
            travel_to Time.zone.local(2022, 2, 16, 10, 0, 0) do
              demand = Fabricate :demand, company: company
              discarded_demand = Fabricate :demand, company: company, discarded_at: 2.days.ago
              task = Fabricate :task, demand: demand, created_date: 2.days.ago, end_date: nil
              other_task = Fabricate :task, demand: demand, created_date: 1.day.ago, end_date: nil
              Fabricate :task, demand: discarded_demand, created_date: 1.day.ago, end_date: nil
              Fabricate :task, demand: demand, created_date: 3.days.ago, end_date: nil

              post :search, params: { company_id: company, tasks_start_date: 52.hours.ago.to_date, tasks_end_date: 1.minute.ago.to_date, task_status: 'not_finished' }

              expect(assigns(:tasks)).to eq [other_task, task]
              expect(response).to render_template :index
            end
          end
        end

        context 'with search by tasks dates with the status closed' do
          it 'searches by end date and renders the template' do
            travel_to Time.zone.local(2022, 2, 16, 10, 0, 0) do
              demand = Fabricate :demand, company: company
              discarded_demand = Fabricate :demand, company: company, discarded_at: 2.days.ago

              task = Fabricate :task, demand: demand, created_date: 2.days.ago, end_date: 1.day.ago
              other_task = Fabricate :task, demand: demand, created_date: 1.day.ago, end_date: 1.hour.ago
              Fabricate :task, demand: discarded_demand, created_date: 1.day.ago, end_date: 1.hour.ago
              Fabricate :task, demand: demand, created_date: 3.days.ago, end_date: nil
              Fabricate :task, demand: demand, created_date: 4.days.ago, end_date: 3.days.ago

              post :search, params: { company_id: company, tasks_start_date: 26.hours.ago.to_date, tasks_end_date: 1.minute.ago.to_date, task_status: 'finished' }

              expect(assigns(:tasks)).to eq [other_task, task]
              expect(response).to render_template :index
            end
          end
        end

        context 'with no search params' do
          it 'assigns the instance variables and renders the template' do
            travel_to Time.zone.local(2022, 2, 16, 10, 0, 0) do
              demand = Fabricate :demand, company: company
              task = Fabricate :task, demand: demand, created_date: 2.days.ago, title: 'fOo'
              other_task = Fabricate :task, demand: demand, created_date: 1.day.ago, title: 'fOObar'
              another_task = Fabricate :task, demand: demand, created_date: Time.zone.now, title: 'xpto'

              post :search, params: { company_id: company }

              expect(assigns(:tasks)).to eq [another_task, other_task, task]
              expect(response).to render_template :index
            end
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
            travel_to Time.zone.local(2022, 2, 16, 10, 0, 0) do
              demand = Fabricate :demand, company: company
              task = Fabricate :task, demand: demand, created_date: 2.days.ago, end_date: Time.zone.now, title: 'fOo'
              other_task = Fabricate :task, demand: demand, created_date: 1.day.ago, end_date: 2.hours.ago, title: 'fOObar'
              Fabricate :task, demand: demand, created_date: Time.zone.now, title: 'xpto'

              finished_tasks = Task.finished

              post :charts, params: { company_id: company, tasks_search: 'foo' }

              expect(assigns(:tasks)).to eq [other_task, task]
              expect(assigns(:task_completion_control_chart_data).pluck(:id)).to eq [other_task.external_id, task.external_id]
              expect(assigns(:task_completion_control_chart_data).pluck(:completion_time)).to eq [other_task.seconds_to_complete, task.seconds_to_complete]
              expect(assigns(:tasks_charts_adapter).x_axis).to eq TimeService.instance.weeks_between_of(finished_tasks.map(&:end_date).min, finished_tasks.map(&:end_date).max)
              expect(assigns(:tasks_charts_adapter).throughput_chart_data).to eq [2]
              expect(assigns(:tasks_charts_adapter).completion_percentiles_on_time_chart_data).to eq({ y_axis: [{ data: [1.7833333333333334], name: 'Lead time (80%)' }, { data: [1.7833333333333334], name: 'Lead time 80% acumulado' }] })

              expect(response).to render_template :charts
            end
          end
        end

        context 'with no search' do
          it 'assigns the chart variable with the finished tasks and renders the template' do
            travel_to Time.zone.local(2022, 2, 16, 10, 0, 0) do
              demand = Fabricate :demand, company: company

              finished_task = Fabricate :task, demand: demand, created_date: 2.days.ago, end_date: Time.zone.now, title: 'fOo', external_id: 'jupiter'
              other_finished_task = Fabricate :task, demand: demand, created_date: 1.day.ago, end_date: 2.hours.ago, title: 'fOObar', external_id: 'pluto'
              wip_task = Fabricate :task, demand: demand, created_date: 5.hours.ago, title: 'xpto', external_id: 'mars'
              other_wip_task = Fabricate :task, demand: demand, created_date: 3.days.ago, title: 'sbbrubles', external_id: 'venus'

              post :charts, params: { company_id: company }

              expect(assigns(:tasks)).to eq [wip_task, other_finished_task, finished_task, other_wip_task]
              expect(assigns(:task_completion_control_chart_data).pluck(:id)).to eq [other_finished_task.external_id, finished_task.external_id]
              expect(assigns(:task_completion_control_chart_data).pluck(:completion_time)).to eq [other_finished_task.seconds_to_complete, finished_task.seconds_to_complete]
              expect(assigns(:task_wip_completion_control_chart_data).pluck(:id)).to eq [other_wip_task.external_id, wip_task.external_id]
              expect(assigns(:task_wip_completion_control_chart_data).pluck(:completion_time)).to eq [wip_task.partial_completion_time, other_wip_task.partial_completion_time]

              expect(response).to render_template :charts
            end
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
