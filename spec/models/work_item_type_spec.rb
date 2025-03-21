# frozen_string_literal: true

RSpec.describe WorkItemType do
  context 'enums' do
    it { is_expected.to define_enum_for(:item_level).with_values(demand: 0) }
  end

  context 'associations' do
    it { is_expected.to belong_to :company }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_presence_of :item_level }
    end

    context 'uniqueness' do
      it 'does not accept the same name, company and item level' do
        company = Fabricate :company

        control_type = Fabricate :work_item_type, company: company, name: 'foo'
        dup_type = Fabricate.build :work_item_type, company: company, name: 'foo'
        diff_name_type = Fabricate.build :work_item_type, company: company, name: 'bar'
        diff_company_type = Fabricate.build :work_item_type, name: 'bar'
        diff_level_type = Fabricate.build :work_item_type, name: 'bar'

        expect(control_type).to be_valid

        expect(dup_type).not_to be_valid
        expect(dup_type.errors.full_messages).to eq ['Nome já está em uso']

        expect(diff_name_type).to be_valid
        expect(diff_company_type).to be_valid
        expect(diff_level_type).to be_valid
      end
    end
  end
end
