# frozen_string_literal: true

Fabricator(:score_matrix_question) do
  score_matrix

  question_weight { [10, 20, 30].sample }

  description { %w[bla xpto foo bar sbbrubles].sample }
end
