# frozen_string_literal: true

RSpec.describe FlowConsolidation, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :team }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :team }
    it { is_expected.to validate_presence_of :average_customer_happiness }
    it { is_expected.to validate_presence_of :consolidation_date }
    it { is_expected.to validate_presence_of :current_wip }
    it { is_expected.to validate_presence_of :demands_ids }
    it { is_expected.to validate_presence_of :demands_lead_times }
    it { is_expected.to validate_presence_of :demands_lead_times_average }
    it { is_expected.to validate_presence_of :demands_lead_times_std_dev }
    it { is_expected.to validate_presence_of :histogram_range }
    it { is_expected.to validate_presence_of :interquartile_range }
    it { is_expected.to validate_presence_of :last_lead_time_p80 }
    it { is_expected.to validate_presence_of :last_throughput_per_week_data }
    it { is_expected.to validate_presence_of :lead_time_histogram_bin_max }
    it { is_expected.to validate_presence_of :lead_time_histogram_bin_min }
    it { is_expected.to validate_presence_of :lead_time_max }
    it { is_expected.to validate_presence_of :lead_time_min }
    it { is_expected.to validate_presence_of :lead_time_p25 }
    it { is_expected.to validate_presence_of :lead_time_p75 }
    it { is_expected.to validate_presence_of :population_end_date }
    it { is_expected.to validate_presence_of :population_start_date }
    it { is_expected.to validate_presence_of :projects_ids }
    it { is_expected.to validate_presence_of :total_range }
    it { is_expected.to validate_presence_of :wip_limit }
    it { is_expected.to validate_presence_of :flow_pressure }
    it { is_expected.to validate_presence_of :flow_total_cost }
  end
end
