# frozen_string_literal: true

# == Schema Information
#
# Table name: score_matrices
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :integer          not null
#
# Indexes
#
#  index_score_matrices_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_a144912394  (product_id => products.id)
#

class ScoreMatrix < ApplicationRecord
  belongs_to :product

  has_many :score_matrix_questions, dependent: :destroy

  def total_weight
    score_matrix_questions.filter_map(&:question_weight).sum
  end

  def single_dimension?
    questions_dimensions.count < 2
  end

  def questions_dimensions
    score_matrix_questions.map(&:question_type).uniq
  end
end
