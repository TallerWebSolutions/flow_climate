# frozen_string_literal: true

RSpec.describe TasksController, type: :controller do
  context 'unauthenticated' do
    describe '#index' do
      before { get :index, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }

    before { sign_in user }

    describe '#index' do
      context 'with valid params' do
        context 'with data' do
          it 'assigns the instance variables and renders the template' do
            demand = Fabricate :demand, company: company
            task = Fabricate :task, demand: demand, created_date: 1.day.ago
            other_task = Fabricate :task, demand: demand, created_date: Time.zone.now

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
  end
end
