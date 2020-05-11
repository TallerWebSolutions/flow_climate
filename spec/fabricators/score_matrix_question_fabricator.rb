# frozen_string_literal: true

Fabricator(:score_matrix_question) do
  score_matrix

  description { %w[bla xpto foo bar sbbrubles].sample }
end
