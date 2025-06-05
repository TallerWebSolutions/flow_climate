# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CompanyWorkingHoursConfig do
  let(:company) { Fabricate :company }

  describe 'associations' do
    it { is_expected.to belong_to(:company) }
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active_config) { Fabricate :company_working_hours_config, active: true }
      let!(:inactive_config) { Fabricate :company_working_hours_config, active: false }

      it 'returns only active configs' do
        expect(described_class.active).to include(active_config)
        expect(described_class.active).not_to include(inactive_config)
      end
    end

    describe '.for_date' do
      let(:date) { Time.zone.today }
      let!(:config_before) { Fabricate :company_working_hours_config, start_date: date - 1.day, end_date: date - 1.day }
      let!(:config_during) { Fabricate :company_working_hours_config, start_date: date - 1.day, end_date: date + 1.day }
      let!(:config_after) { Fabricate :company_working_hours_config, start_date: date + 1.day, end_date: date + 2.days }
      let!(:config_no_end) { Fabricate :company_working_hours_config, start_date: date - 1.day, end_date: nil }
      let!(:inactive_config) { Fabricate :company_working_hours_config, start_date: date - 1.day, end_date: date + 1.day, active: false }

      it 'returns configs active on the given date' do
        expect(described_class.for_date(date)).to include(config_during, config_no_end)
        expect(described_class.for_date(date)).not_to include(config_before, config_after, inactive_config)
      end
    end
  end

  describe '#active_now?' do
    it 'returns true if today is within the config period' do
      config = described_class.new(company: company, hours_per_day: 8, start_date: 2.days.ago, end_date: 2.days.from_now)
      expect(config.active_now?).to be true
    end

    it 'returns false if today is before the start_date' do
      config = described_class.new(company: company, hours_per_day: 8, start_date: 2.days.from_now, end_date: nil)
      expect(config.active_now?).to be false
    end

    it 'returns false if today is after the end_date' do
      config = described_class.new(company: company, hours_per_day: 8, start_date: 5.days.ago, end_date: 2.days.ago)
      expect(config.active_now?).to be false
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:hours_per_day) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_numericality_of(:hours_per_day).is_greater_than(0).is_less_than_or_equal_to(24) }

    it 'is invalid if end_date is before start_date' do
      config = described_class.new(company: company, hours_per_day: 8, start_date: Date.today, end_date: Date.yesterday)
      expect(config).not_to be_valid
      expect(config.errors[:end_date]).to include('must be after start date')
    end

    it 'is invalid if overlaps with another config for the same company' do
      described_class.create!(company: company, hours_per_day: 8, start_date: Date.today, end_date: nil)
      overlapping = described_class.new(company: company, hours_per_day: 6, start_date: Date.today, end_date: nil)
      expect(overlapping).not_to be_valid
      expect(overlapping.errors[:base]).to include('overlaps with existing configuration period')
    end

    it 'is valid if does not overlap with another config' do
      described_class.create!(company: company, hours_per_day: 8, start_date: 10.days.ago, end_date: 5.days.ago)
      config = described_class.new(company: company, hours_per_day: 6, start_date: 4.days.ago, end_date: nil)
      expect(config).to be_valid
    end
  end
end
