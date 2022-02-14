# frozen_string_literal: true

RSpec.describe RiskReviewActionItemsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', product_id: 'foo', risk_review_id: 'bla' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', product_id: 'foo', risk_review_id: 'bla' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', product_id: 'bar', risk_review_id: 'sbbrubles', id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer }
    let(:risk_review) { Fabricate :risk_review, product: product }

    shared_context 'risk review action items data' do
      let!(:first_risk_action) { Fabricate :risk_review_action_item, risk_review: risk_review, deadline: 2.days.from_now }
      let!(:second_risk_action) { Fabricate :risk_review_action_item, risk_review: risk_review, deadline: 3.days.ago }

      let!(:other_risk_action) { Fabricate :risk_review_action_item, deadline: 3.days.ago }

      let(:team) { Fabricate :team, company: company }
      let!(:project) { Fabricate :project, team: team, customers: [customer], products: [product] }

      let(:team_member) { Fabricate :team_member, company: company, name: 'zzz' }
      let!(:membership) { Fabricate :membership, team_member: team_member, team: team, end_date: nil }

      let(:other_team_member) { Fabricate :team_member, company: company, name: 'aaa' }
      let!(:other_membership) { Fabricate :membership, team_member: other_team_member, team: team, end_date: nil }

      let!(:inactive_membership) { Fabricate :membership, team_member: other_team_member, team: team, end_date: Time.zone.yesterday }
    end

    before { sign_in user }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, product_id: product, risk_review_id: risk_review }, xhr: true }

        it 'instantiates a new risk review action item and renders the templates' do
          expect(response).to render_template 'risk_review_action_items/new'
          expect(response).to render_template 'risk_review_action_items/_new'
          expect(response).to render_template 'risk_review_action_items/_form'
          expect(assigns(:risk_review_action_item)).to be_a_new RiskReviewActionItem
        end
      end

      context 'invalid' do
        context 'non-existent risk review' do
          before { get :new, params: { company_id: company, product_id: product, risk_review_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent product' do
          before { get :new, params: { company_id: company, product_id: 'foo', risk_review_id: risk_review }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo', product_id: product, risk_review_id: risk_review }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company, product_id: product, risk_review_id: risk_review }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      include_context 'risk review action items data'

      context 'passing valid parameters' do
        it 'creates the new risk review action item' do
          post :create, params: { company_id: company, product_id: product, risk_review_id: risk_review, risk_review_action_item: { created_date: Time.zone.today, deadline: Time.zone.tomorrow, description: 'bar', membership_id: membership.id, action_type: :customer_alignment } }, xhr: true

          expect(response).to render_template 'risk_review_action_items/create'
          expect(response).to render_template 'risk_review_action_items/_risk_review_action_items_table'

          action_item_created = assigns(:risk_review_action_item)
          expect(action_item_created.errors.full_messages).to eq []
          expect(action_item_created).to be_persisted
          expect(action_item_created.created_date).to eq Time.zone.today
          expect(action_item_created.deadline).to eq Time.zone.tomorrow
          expect(action_item_created.description).to eq 'bar'
          expect(action_item_created.membership).to eq membership
          expect(assigns(:memberships)).to eq [other_membership, membership]
          expect(assigns(:risk_review_action_items)).to eq [second_risk_action, action_item_created, first_risk_action]
        end
      end

      context 'invalid' do
        context 'parameters' do
          it 'does not create the review and re-render the template with the errors' do
            post :create, params: { company_id: company, product_id: product, risk_review_id: risk_review, risk_review_action_item: { created_date: nil, deadline: nil, description: nil, membership_id: nil, action_type: nil } }, xhr: true

            expect(RiskReviewActionItem.all.count).to eq 3
            expect(response).to render_template 'risk_review_action_items/create'
            expect(assigns(:risk_review_action_item).errors.full_messages).to eq ['Responsável deve existir', 'Dt Criação não pode ficar em branco', 'Tipo da Ação não pode ficar em branco', 'Descrição não pode ficar em branco', 'Prazo não pode ficar em branco']
          end

          context 'risk review' do
            before { post :create, params: { company_id: 'foo', product_id: product, risk_review_id: 'foo' }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'product' do
            before { post :create, params: { company_id: company, product_id: 'foo', risk_review_id: risk_review }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'company' do
            before { post :create, params: { company_id: 'foo', product_id: product, risk_review_id: risk_review }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted company' do
            let(:company) { Fabricate :company, users: [] }

            before { post :create, params: { company_id: company, product_id: product, risk_review_id: risk_review }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      include_context 'risk review action items data'

      context 'with valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, product_id: product, risk_review_id: risk_review, id: first_risk_action }, xhr: true }

          it 'deletes the action item and renders the template' do
            expect(response).to render_template 'risk_review_action_items/destroy'
            expect(response).to render_template 'risk_review_action_items/_risk_review_action_items_table'
            expect(RiskReviewActionItem.all).to match_array [second_risk_action, other_risk_action]
          end
        end
      end

      context 'invalid' do
        context 'non-existent action item' do
          before { delete :destroy, params: { company_id: company, product_id: product, risk_review_id: risk_review, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent product' do
          before { delete :destroy, params: { company_id: company, product_id: 'foo', risk_review_id: risk_review, id: first_risk_action } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'other risk review' do
          before { delete :destroy, params: { company_id: company, product_id: product, risk_review_id: risk_review, id: other_risk_action } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', product_id: product, risk_review_id: risk_review, id: first_risk_action } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, product_id: product, risk_review_id: risk_review, id: first_risk_action } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
