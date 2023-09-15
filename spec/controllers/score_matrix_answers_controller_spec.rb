# frozen_string_literal: true

RSpec.describe ScoreMatrixAnswersController do
  context 'unauthenticated' do
    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', product_id: 'foo', score_matrix_question_id: 'xpto' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'bar', product_id: 'foo', score_matrix_question_id: 'xpto', id: 'bar' } }

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
    let!(:score_matrix) { Fabricate :score_matrix, product: product }
    let!(:score_matrix_question) { Fabricate :score_matrix_question, score_matrix: score_matrix }

    describe 'POST #create' do
      context 'with valid data' do
        it 'creates the portfolio unit and renders the template' do
          post :create, params: { company_id: company, product_id: product, score_matrix_question_id: score_matrix_question, score_matrix_answer: { answer_value: 2, description: 'bla' } }

          created_answer = ScoreMatrixAnswer.last

          expect(created_answer.score_matrix_question).to be_a ScoreMatrixQuestion
          expect(created_answer.answer_value).to eq 2
          expect(created_answer.description).to eq 'bla'

          expect(flash[:notice]).to eq I18n.t('score_matrix_answers.create.success')

          expect(response).to redirect_to company_product_score_matrix_question_path(company, product, score_matrix_question)
        end
      end

      context 'with invalid' do
        context 'parameters' do
          it 'adds errors to the model and to flash' do
            post :create, params: { company_id: company, product_id: product, score_matrix_question_id: score_matrix_question, score_matrix_answer: { answer_value: nil, description: nil } }

            expect(assigns(:score_matrix_answer).errors.full_messages).to eq ['Descrição não pode ficar em branco', 'Valor da Resposta não pode ficar em branco']
            expect(flash[:error]).to eq 'Descrição não pode ficar em branco, Valor da Resposta não pode ficar em branco'
            expect(response).to redirect_to company_product_score_matrix_question_path(company, product, score_matrix_question)
          end
        end

        context 'score_matrix_question' do
          before { post :create, params: { company_id: company, product_id: product, score_matrix_question_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product' do
          before { post :create, params: { company_id: company, product_id: 'foo', score_matrix_question_id: score_matrix_question } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'product in other company' do
          let(:other_product) { Fabricate :product }

          before { post :create, params: { company_id: company, product_id: other_product, score_matrix_question_id: score_matrix_question } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          before { post :create, params: { company_id: 'foo', product_id: product, score_matrix_question_id: score_matrix_question } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:other_company) { Fabricate :company }

          before { post :create, params: { company_id: other_company, product_id: product, score_matrix_question_id: score_matrix_question } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let!(:score_matrix_answer) { Fabricate :score_matrix_answer, score_matrix_question: score_matrix_question, answer_value: 0 }

      let!(:first_score_matrix_answer) { Fabricate :score_matrix_answer, score_matrix_question: score_matrix_question, answer_value: 3, description: 'first_answer' }
      let!(:second_score_matrix_answer) { Fabricate :score_matrix_answer, score_matrix_question: score_matrix_question, answer_value: 2, description: 'second_answer' }
      let!(:third_score_matrix_answer) { Fabricate :score_matrix_answer, score_matrix_question: score_matrix_question, answer_value: 1, description: 'third_answer' }
      let!(:fourth_score_matrix_answer) { Fabricate :score_matrix_answer, score_matrix_question: score_matrix_question, answer_value: 4, description: 'fourth_answer' }

      context 'valid parameters' do
        before { delete :destroy, params: { company_id: company, product_id: product, score_matrix_question_id: score_matrix_question, id: score_matrix_answer }, xhr: true }

        it 'deletes the score matrix' do
          expect(response).to render_template 'score_matrix_answers/_score_matrix_answers_table'
          expect(response).to render_template 'score_matrix_answers/destroy'
          expect(ScoreMatrixAnswer.count).to eq 4
          expect(assigns(:score_matrix_answers)).to eq [third_score_matrix_answer, second_score_matrix_answer, first_score_matrix_answer, fourth_score_matrix_answer]
        end
      end

      context 'invalid parameters' do
        context 'score_matrix_question' do
          before { post :create, params: { company_id: company, product_id: product, score_matrix_question_id: 'foo', id: score_matrix_answer } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent score_matrix_question' do
          before { delete :destroy, params: { company_id: company, product_id: product, score_matrix_question_id: score_matrix_question, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent product' do
          before { delete :destroy, params: { company_id: company, product_id: 'foo', score_matrix_question_id: score_matrix_question, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', product_id: product, score_matrix_question_id: score_matrix_question, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, product_id: product, score_matrix_question_id: score_matrix_question, id: score_matrix_question }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
