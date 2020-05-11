# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_score_matrices
#
#  id                     :bigint           not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  demand_id              :integer          not null
#  score_matrix_answer_id :integer          not null
#  user_id                :integer          not null
#
# Indexes
#
#  idx_demand_score_matrices_unique                       (demand_id,user_id,score_matrix_answer_id) UNIQUE
#  index_demand_score_matrices_on_demand_id               (demand_id)
#  index_demand_score_matrices_on_score_matrix_answer_id  (score_matrix_answer_id)
#  index_demand_score_matrices_on_user_id                 (user_id)
#
# Foreign Keys
#
#  fk_rails_11c172ae9a  (score_matrix_answer_id => score_matrix_answers.id)
#  fk_rails_73167e8e2c  (user_id => users.id)
#  fk_rails_ea77f40fb8  (demand_id => demands.id)
#
class DemandScoreMatrix < ApplicationRecord
  belongs_to :user
  belongs_to :demand
  belongs_to :score_matrix_answer

  validates :user, :demand, :score_matrix_answer, presence: true

  validates :demand, uniqueness: { scope: %i[user demand score_matrix_answer], message: I18n.t('activerecord.errors.models.demand_score_matrix.uniqueness') }
end
