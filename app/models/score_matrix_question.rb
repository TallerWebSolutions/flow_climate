# frozen_string_literal: true

# == Schema Information
#
# Table name: score_matrix_questions
#
#  id              :bigint           not null, primary key
#  description     :string           not null
#  question_type   :integer          default("customer_dimension"), not null
#  question_weight :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  score_matrix_id :integer          not null
#
# Indexes
#
#  index_score_matrix_questions_on_score_matrix_id  (score_matrix_id)
#
# Foreign Keys
#
#  fk_rails_383aa02a04  (score_matrix_id => score_matrices.id)
#
class ScoreMatrixQuestion < ApplicationRecord
  enum :question_type, { customer_dimension: 0, service_provider_dimension: 1 }

  belongs_to :score_matrix

  has_many :score_matrix_answers, dependent: :destroy

  validates :description, :question_type, :question_weight, presence: true
end
