# frozen_string_literal: true

RSpec.describe ScoreMatrixQuestionsController do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', product_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', product_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'bar', product_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'bar', product_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'bar', product_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'bar', product_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer }
    let(:score_matrix) { Fabricate :score_matrix, product: product }

    describe 'GET #new' do
      context 'with valid data' do
        it 'assigns the instance variables and render the template' do
          get :new, params: { company_id: company, product_id: product }, xhr: true

          expect(assigns(:company)).to eq company
          expect(assigns(:product)).to eq product
          expect(assigns(:score_matrix_question)).to be_a_new ScoreMatrixQuestion
          expect(assigns(:score_matrix_question).score_matrix).to be_a ScoreMatrix
          expect(response).to render_template 'score_matrix_questions/new'
        end
      end

      context 'with invalid' do
        context 'product' do
          before { get :new, params: { company_id: company, product_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product in other company' do
          let(:other_product) { Fabricate :product }

          before { get :new, params: { company_id: company, product_id: other_product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          before { get :new, params: { company_id: 'foo', product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:other_company) { Fabricate :company }

          before { get :new, params: { company_id: other_company, product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'with valid data' do
        it 'creates the portfolio unit and renders the template' do
          demand = Fabricate :demand, product: product, demand_score: 20

          first_question = Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20
          second_question = Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 10
          third_question = Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 25

          first_answer = Fabricate :score_matrix_answer, score_matrix_question: first_question, answer_value: 5
          second_answer = Fabricate :score_matrix_answer, score_matrix_question: second_question, answer_value: 0
          Fabricate :score_matrix_answer, score_matrix_question: third_question, answer_value: 3

          Fabricate :demand_score_matrix, user: user, demand: demand, score_matrix_answer: first_answer
          Fabricate :demand_score_matrix, user: user, demand: demand, score_matrix_answer: second_answer

          post :create, params: { company_id: company, product_id: product, score_matrix_question: { description: 'bla', question_type: :service_provider_dimension, question_weight: 40 } }, xhr: true

          created_question = ScoreMatrixQuestion.last

          expect(created_question.score_matrix).to be_a ScoreMatrix
          expect(created_question.question_type).to eq 'service_provider_dimension'
          expect(created_question.description).to eq 'bla'
          expect(created_question.question_weight).to eq 40

          expect(demand.reload.demand_score).to eq 1.052631578947368

          expect(flash[:notice]).to eq I18n.t('score_matrix_questions.create.success')

          expect(response).to redirect_to company_product_path(company, product)
        end
      end

      context 'with invalid' do
        context 'parameters' do
          it 'adds errors to the model and to flash' do
            post :create, params: { company_id: company, product_id: product, score_matrix_question: { description: nil, question_type: nil, question_weight: nil } }, xhr: true

            expect(assigns(:score_matrix_question).errors.full_messages).to eq ['Descrição não pode ficar em branco', 'Tipo não pode ficar em branco', 'Peso não pode ficar em branco']
            expect(flash[:error]).to eq 'Descrição não pode ficar em branco, Tipo não pode ficar em branco, Peso não pode ficar em branco'
            expect(response).to render_template 'score_matrix_questions/new'
          end
        end

        context 'product' do
          before { post :create, params: { company_id: company, product_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product in other company' do
          let(:other_product) { Fabricate :product }

          before { post :create, params: { company_id: company, product_id: other_product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          before { post :create, params: { company_id: 'foo', product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:other_company) { Fabricate :company }

          before { post :create, params: { company_id: other_company, product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let!(:score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix }

      let!(:first_score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_type: :customer_dimension, question_weight: 10, description: 'first_question' }
      let!(:second_score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_type: :service_provider_dimension, question_weight: 20, description: 'second_question' }
      let!(:third_score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_type: :service_provider_dimension, question_weight: 20, description: 'third_question' }
      let!(:fourth_score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_type: :service_provider_dimension, question_weight: 5, description: 'fourth_question' }

      context 'valid parameters' do
        before { delete :destroy, params: { company_id: company, product_id: product, id: score_matrix_question }, xhr: true }

        it 'deletes the score matrix' do
          expect(response).to render_template 'score_matrix_questions/destroy'
          expect(ScoreMatrixQuestion.count).to eq 4
          expect(assigns(:score_matrix_questions)).to eq [first_score_matrix_question, fourth_score_matrix_question, second_score_matrix_question, third_score_matrix_question]
        end
      end

      context 'invalid parameters' do
        context 'non-existent product jira config' do
          before { delete :destroy, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent product' do
          before { delete :destroy, params: { company_id: company, product_id: 'foo', id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', product_id: product, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, product_id: product, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #show' do
      let(:score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix }

      let!(:score_matrix_answer) { Fabricate :score_matrix_answer, score_matrix_question: score_matrix_question, answer_value: 1 }
      let!(:other_score_matrix_answer) { Fabricate :score_matrix_answer, score_matrix_question: score_matrix_question, answer_value: 0 }

      let!(:out_score_matrix_answer) { Fabricate :score_matrix_answer }

      context 'with valid data' do
        it 'assigns the instance variables and render the template' do
          get :show, params: { company_id: company, product_id: product, id: score_matrix_question }, xhr: true

          expect(assigns(:company)).to eq company
          expect(assigns(:product)).to eq product
          expect(assigns(:score_matrix_question)).to eq score_matrix_question
          expect(assigns(:score_matrix_answers)).to eq [other_score_matrix_answer, score_matrix_answer]
          expect(response).to render_template 'score_matrix_questions/show'
        end
      end

      context 'with invalid' do
        context 'score_matrix_question' do
          before { get :show, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product' do
          before { get :show, params: { company_id: company, product_id: 'foo', id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product in other company' do
          let(:other_product) { Fabricate :product }

          before { get :show, params: { company_id: company, product_id: other_product, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          before { get :show, params: { company_id: 'foo', product_id: product, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:other_company) { Fabricate :company }

          before { get :new, params: { company_id: other_company, product_id: product }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let!(:score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, description: 'zzz' }

      context 'with valid data' do
        it 'assigns the instance variables and render the template' do
          get :edit, params: { company_id: company, product_id: product, id: score_matrix_question }, xhr: true
          expect(assigns(:company)).to eq company
          expect(assigns(:product)).to eq product
          expect(assigns(:score_matrix_question)).to eq score_matrix_question
          expect(response).to render_template 'score_matrix_questions/edit'
        end
      end

      context 'with invalid' do
        context 'portfolio unit' do
          before { get :edit, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product' do
          before { get :edit, params: { company_id: company, product_id: 'foo', id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product in other company' do
          let(:other_product) { Fabricate :product }

          before { get :edit, params: { company_id: company, product_id: other_product, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          before { get :edit, params: { company_id: 'foo', product_id: product, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:other_company) { Fabricate :company }

          before { get :edit, params: { company_id: other_company, product_id: product, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PUT #update' do
      let!(:score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, description: 'zzz' }

      context 'with valid data' do
        it 'updates the portfolio unit and renders the template' do
          demand = Fabricate :demand, product: product, demand_score: 20

          first_question = Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20
          second_question = Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 10
          third_question = Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 25

          first_answer = Fabricate :score_matrix_answer, score_matrix_question: first_question, answer_value: 5
          second_answer = Fabricate :score_matrix_answer, score_matrix_question: second_question, answer_value: 0
          Fabricate :score_matrix_answer, score_matrix_question: third_question, answer_value: 3

          Fabricate :demand_score_matrix, user: user, demand: demand, score_matrix_answer: first_answer
          Fabricate :demand_score_matrix, user: user, demand: demand, score_matrix_answer: second_answer

          put :update, params: { company_id: company, product_id: product, id: score_matrix_question, score_matrix_question: { description: 'bla', question_type: :service_provider_dimension, question_weight: 10 } }, xhr: true

          updated_question = score_matrix_question.reload
          expect(updated_question.score_matrix).to be_a ScoreMatrix
          expect(updated_question.question_type).to eq 'service_provider_dimension'
          expect(updated_question.description).to eq 'bla'
          expect(updated_question.question_weight).to eq 10

          expect(demand.reload.demand_score.to_f).to eq 1.538461538461538

          expect(response).to redirect_to company_product_path(company, product)
        end
      end

      context 'with invalid' do
        context 'parameters' do
          it 'adds errors to the model and to flash' do
            put :update, params: { company_id: company, product_id: product, id: score_matrix_question, score_matrix_question: { description: nil, question_type: nil, question_weight: nil } }, xhr: true

            expect(assigns(:score_matrix_question).errors.full_messages).to eq ['Descrição não pode ficar em branco', 'Tipo não pode ficar em branco', 'Peso não pode ficar em branco']
            expect(flash[:error]).to eq 'Descrição não pode ficar em branco, Tipo não pode ficar em branco, Peso não pode ficar em branco'
            expect(response).to render_template 'score_matrix_questions/edit'
          end
        end

        context 'portfolio unit' do
          before { put :update, params: { company_id: company, product_id: product, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product' do
          before { put :update, params: { company_id: company, product_id: 'foo', id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product in other company' do
          let(:other_product) { Fabricate :product }

          before { put :update, params: { company_id: company, product_id: other_product, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          before { put :update, params: { company_id: 'foo', product_id: product, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:other_company) { Fabricate :company }

          before { put :update, params: { company_id: other_company, product_id: product, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
