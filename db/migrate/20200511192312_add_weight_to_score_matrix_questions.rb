# frozen_string_literal: true

class AddWeightToScoreMatrixQuestions < ActiveRecord::Migration[6.0]
  def change
    add_column :score_matrix_questions, :question_weight, :integer, null: false

    remove_index :demand_score_matrices, column: %i[demand_id user_id score_matrix_answer_id], unique: true, name: 'idx_demand_score_matrices_unique'
  end
end
