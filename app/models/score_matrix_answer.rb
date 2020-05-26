# frozen_string_literal: true

# == Schema Information
#
# Table name: score_matrix_answers
#
#  id                       :bigint           not null, primary key
#  answer_value             :integer          not null
#  description              :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  score_matrix_question_id :integer          not null
#
# Indexes
#
#  idx_demand_score_answers_unique                         (answer_value,score_matrix_question_id) UNIQUE
#  index_score_matrix_answers_on_score_matrix_question_id  (score_matrix_question_id)
#
# Foreign Keys
#
#  fk_rails_0429e0abf2  (score_matrix_question_id => score_matrix_questions.id)
#
class ScoreMatrixAnswer < ApplicationRecord
  belongs_to :score_matrix_question

  validates :score_matrix_question, :description, :answer_value, presence: true

  validates :answer_value, uniqueness: { scope: :score_matrix_question, message: I18n.t('activerecord.errors.models.score_matrix_answer.value_already_used') }

  def answer_score
    answer_value * score_matrix_question.question_weight
  end
end
