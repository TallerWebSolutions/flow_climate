# frozen_string_literal: true

class CreateScoreMatrices < ActiveRecord::Migration[6.0]
  def change
    create_table :score_matrices do |t|
      t.integer :product_id, index: true, null: false

      t.timestamps
    end
    add_foreign_key :score_matrices, :products, column: :product_id

    create_table :score_matrix_questions do |t|
      t.integer :score_matrix_id, index: true, null: false
      t.integer :question_type, null: false, default: 0
      t.string :description, null: false

      t.timestamps
    end
    add_foreign_key :score_matrix_questions, :score_matrices, column: :score_matrix_id

    create_table :score_matrix_answers do |t|
      t.integer :score_matrix_question_id, index: true, null: false
      t.string :description, null: false
      t.integer :answer_value, null: false

      t.timestamps
    end
    add_foreign_key :score_matrix_answers, :score_matrix_questions, column: :score_matrix_question_id

    create_table :demand_score_matrices do |t|
      t.integer :demand_id, index: true, null: false
      t.integer :user_id, index: true, null: false
      t.integer :score_matrix_answer_id, index: true, null: false

      t.timestamps
    end
    add_foreign_key :demand_score_matrices, :demands, column: :demand_id
    add_foreign_key :demand_score_matrices, :users, column: :user_id
    add_foreign_key :demand_score_matrices, :score_matrix_answers, column: :score_matrix_answer_id

    add_index :demand_score_matrices, %i[demand_id user_id score_matrix_answer_id], unique: true, name: 'idx_demand_score_matrices_unique'
  end
end
