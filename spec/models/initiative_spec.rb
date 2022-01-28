# frozen-string-literal: true

RSpec.describe Initiative, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many(:projects).dependent(:destroy) }
    it { is_expected.to have_many(:demands).through(:projects) }
    it { is_expected.to have_many(:tasks).through(:projects) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :name }
    end

    context 'complex ones' do
      context 'uniqueness' do
        it 'does not accept initiatives using the same name inside the same company' do
          company = Fabricate :company
          first_initiative = Fabricate :initiative, company: company, name: 'foo'
          second_initiative = Fabricate :initiative, company: company
          third_initiative = Fabricate :initiative, name: 'foo'
          invalid = Fabricate.build :initiative, company: company, name: 'foo'

          expect(first_initiative.valid?).to eq true
          expect(second_initiative.valid?).to eq true
          expect(third_initiative.valid?).to eq true
          expect(invalid.valid?).to eq false
        end
      end
    end
  end
end
