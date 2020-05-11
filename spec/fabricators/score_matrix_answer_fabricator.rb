# frozen_string_literal: true

Fabricator(:score_matrix_answer) do
  score_matrix_question

  description { %w[bla xpto foo bar sbbrubles].sample }
  answer_value { (0..5).to_a.sample }
end
