# frozen_string_literal: true

RSpec.describe ScoreMatrixQuestion do
  context 'enums' do
    it { is_expected.to define_enum_for(:question_type).with_values(customer_dimension: 0, service_provider_dimension: 1) }
  end

  context 'associations' do
    it { is_expected.to belong_to :score_matrix }
    it { is_expected.to have_many :score_matrix_answers }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :question_type }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :question_weight }
  end
end
