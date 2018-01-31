# frozen_string_literal: true

RSpec.describe CompaniesController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #show' do
      before { get :show, params: { id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #new' do
      before { get :new }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #edit' do
      before { get :edit, params: { id: 'xpto' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { id: 'xpto' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'GET #index' do
      context 'passing a valid ID' do
        let(:company) { Fabricate :company, users: [user], name: 'zzz' }
        let(:other_company) { Fabricate :company, users: [user], name: 'aaa' }
        let(:out_company) { Fabricate :company }
        before { get :index }
        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template :index
          expect(assigns(:companies)).to eq [other_company, company]
        end
      end
    end

    describe 'GET #show' do
      context 'passing a valid ID' do
        let(:company) { Fabricate :company, users: [user] }
        let(:team) { Fabricate :team, company: company }
        let!(:finances) { Fabricate :financial_information, company: company, finances_date: 2.days.ago }
        let!(:other_finances) { Fabricate :financial_information, company: company, finances_date: Time.zone.today }
        let!(:team_member) { Fabricate :team_member, team: team, name: 'zzz' }
        let!(:other_team_member) { Fabricate :team_member, team: team, name: 'aaa' }

        before { get :show, params: { id: company.id } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template :show
          expect(assigns(:company)).to eq company
          expect(assigns(:financial_informations)).to eq [other_finances, finances]
          expect(assigns(:teams)).to eq [team]
        end
      end
      context 'passing an invalid ID' do
        context 'non-existent' do
          before { get :show, params: { id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          before { get :show, params: { id: company } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #new' do
      before { get :new }
      it 'instantiates a new Company and renders the template' do
        expect(response).to render_template :new
        expect(assigns(:company)).to be_a_new Company
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        before { post :create, params: { company: { name: 'foo', abbreviation: 'bar' } } }
        it 'creates the new company and redirects to its show' do
          expect(Company.last.name).to eq 'foo'
          expect(Company.last.abbreviation).to eq 'bar'
          expect(Company.last.users).to eq [user]
          expect(response).to redirect_to company_path(Company.last)
        end
      end
      context 'passing invalid parameters' do
        before { post :create, params: { company: { name: '' } } }
        it 'does not create the company and re-render the template with the errors' do
          expect(Company.last).to be_nil
          expect(response).to render_template :new
          expect(assigns(:company).errors.full_messages).to eq ['Nome não pode ficar em branco', 'Sigla não pode ficar em branco']
        end
      end
    end

    describe 'GET #edit' do
      let(:company) { Fabricate :company, users: [user] }

      context 'valid parameters' do
        before { get :edit, params: { id: company } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
        end
      end

      context 'invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { id: 'foo' } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { get :edit, params: { id: company } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:company) { Fabricate :company, users: [user] }

      context 'passing valid parameters' do
        before { put :update, params: { id: company, company: { name: 'foo', abbreviation: 'bar' } } }
        it 'updates the product and redirects to projects index' do
          expect(Company.last.name).to eq 'foo'
          expect(Company.last.abbreviation).to eq 'bar'
          expect(response).to redirect_to company_path(company)
        end
      end

      context 'passing invalid' do
        context 'product parameters' do
          before { put :update, params: { id: company, company: { name: '', abbreviation: '' } } }
          it 'does not update the product and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:company).errors.full_messages).to eq ['Nome não pode ficar em branco', 'Sigla não pode ficar em branco']
          end
        end
        context 'non-existent company' do
          before { put :update, params: { id: 'foo', product: { name: 'foo', abbreviation: 'bar' } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { put :update, params: { id: company, product: { name: 'foo', abbreviation: 'bar' } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
