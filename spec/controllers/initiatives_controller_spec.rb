# frozen-string-literal: true

RSpec.describe InitiativesController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo' } }

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
            initiative = Fabricate :initiative, company: company, name: 'foo', start_date: 3.days.ago, end_date: 1.day.from_now
            other_initiative = Fabricate :initiative, company: company, name: 'bar', start_date: 2.days.ago, end_date: 2.days.from_now
            Fabricate :initiative

            get :index, params: { company_id: company }

            expect(assigns(:initiatives)).to eq [other_initiative, initiative]
          end
        end
      end

      context 'with invalid params' do
        context 'invalid company' do
          before { get :index, params: { company_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not authorized company' do
          let(:company) { Fabricate :company }

          before { get :index, params: { company_id: company } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
