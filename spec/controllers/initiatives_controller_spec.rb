# frozen-string-literal: true

RSpec.describe InitiativesController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #generate_cache' do
      before { post :generate_cache, params: { company_id: 'foo', id: 'bar' } }

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
            expect(response).to render_template 'initiatives/index'
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

    describe 'GET #show' do
      let(:initiative) { Fabricate :initiative, company: company, name: 'foo', start_date: 3.days.ago, end_date: 1.day.from_now }

      context 'with valid params' do
        context 'with data' do
          it 'assigns the instance variables and renders the template' do
            get :show, params: { company_id: company, id: initiative }

            expect(assigns(:initiative)).to eq initiative
            expect(response).to render_template 'initiatives/show'
          end
        end
      end

      context 'with invalid params' do
        context 'initiative' do
          before { get :show, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'invalid company' do
          before { get :show, params: { company_id: 'foo', id: initiative } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not authorized company' do
          let(:company) { Fabricate :company }

          before { get :show, params: { company_id: company, id: initiative } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #generate_cache' do
      it 'iterates over the dates and calls the job to generate the cache' do
        initiative = Fabricate :initiative, company: company, start_date: 3.days.ago, end_date: 1.day.from_now

        expect(Consolidations::InitiativeConsolidationJob).to(receive(:perform_later).exactly(5).times).and_call_original

        post :generate_cache, params: { company_id: company, id: initiative }
      end
    end
  end
end
