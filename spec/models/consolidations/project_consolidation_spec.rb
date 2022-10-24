# frozen_string_literal: true

RSpec.describe Consolidations::ProjectConsolidation do
  context 'associations' do
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :consolidation_date }
  end

  pending '.weekly_data'
  pending '.for_project'
  pending '.after_date'

  describe '#lead_time_range' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, lead_time_min: 5, lead_time_max: 10 }

      it { expect(project_consolidation.lead_time_range.to_f).to eq 5 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago }

      it { expect(project_consolidation.lead_time_range.to_f).to eq 0 }
    end
  end

  describe '#histogram_range' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, lead_time_histogram_bin_min: 5, lead_time_histogram_bin_max: 10 }

      it { expect(project_consolidation.histogram_range.to_f).to eq 5 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago }

      it { expect(project_consolidation.histogram_range.to_f).to eq 0 }
    end
  end

  describe '#interquartile_range' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, lead_time_p25: 5, lead_time_p75: 10 }

      it { expect(project_consolidation.interquartile_range.to_f).to eq 5 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago }

      it { expect(project_consolidation.interquartile_range.to_f).to eq 0 }
    end
  end

  RSpec.shared_context 'demands with lead time', shared_context: :metadata do
    let(:company) { Fabricate :company }

    let(:feature_type) { Fabricate :work_item_type, company: company, name: 'Feature' }
    let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }
    let(:chore_type) { Fabricate :work_item_type, company: company, name: 'Chore' }

    let(:project) { Fabricate :project, company: company, end_date: 4.weeks.from_now }

    let!(:first_demand) { Fabricate :demand, project: project, commitment_date: 3.days.ago, end_date: 2.hours.ago, work_item_type: feature_type, class_of_service: :standard }
    let!(:second_demand) { Fabricate :demand, project: project, commitment_date: 4.days.ago, end_date: Time.zone.now, work_item_type: feature_type, class_of_service: :fixed_date }
    let!(:third_demand) { Fabricate :demand, project: project, commitment_date: 4.hours.ago, end_date: Time.zone.now, work_item_type: bug_type, class_of_service: :standard }
    let!(:fourth_demand) { Fabricate :demand, project: project, commitment_date: 4.hours.ago, end_date: Time.zone.now, work_item_type: chore_type, class_of_service: :expedite }
    let!(:fifth_demand) { Fabricate :demand, project: project, commitment_date: 4.hours.ago, end_date: Time.zone.now, work_item_type: chore_type, class_of_service: :standard }
    let!(:sixth_demand) { Fabricate :demand, project: project, commitment_date: 4.hours.ago, end_date: Time.zone.now, work_item_type: bug_type, class_of_service: :expedite }
  end

  describe '#lead_time_feature' do
    before { travel_to Time.zone.local(2019, 10, 17, 10, 0, 0) }

    include_context 'demands with lead time'

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_ids: Demand.all.map(&:id) }

      it { expect(project_consolidation.lead_time_feature.to_f).to be_within(0.01).of(326_880.00) }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_ids: [] }

      it { expect(project_consolidation.lead_time_feature.to_f).to eq 0 }
    end
  end

  describe '#lead_time_bug' do
    include_context 'demands with lead time'

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_ids: Demand.all.map(&:id) }

      it { expect(project_consolidation.lead_time_bug.to_f).to be_within(0.01).of(14_400.00) }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_ids: [] }

      it { expect(project_consolidation.lead_time_bug.to_f).to eq 0 }
    end
  end

  describe '#lead_time_chore' do
    include_context 'demands with lead time'

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_ids: Demand.all.map(&:id) }

      it { expect(project_consolidation.lead_time_chore.to_f).to be_within(0.01).of(14_400.00) }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_ids: [] }

      it { expect(project_consolidation.lead_time_chore.to_f).to eq 0 }
    end
  end

  describe '#lead_time_standard' do
    before { travel_to Time.zone.local(2019, 10, 17, 10, 0, 0) }

    include_context 'demands with lead time'

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_ids: Demand.all.map(&:id) }

      it { expect(project_consolidation.lead_time_standard.to_f).to be_within(200).of(156_960.00) }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_ids: [] }

      it { expect(project_consolidation.lead_time_standard.to_f).to eq 0 }
    end
  end

  describe '#lead_time_fixed_date' do
    before { travel_to Time.zone.local(2019, 10, 17, 10, 0, 0) }

    include_context 'demands with lead time'

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_ids: Demand.all.map(&:id) }

      it { expect(project_consolidation.lead_time_fixed_date.to_f).to be_within(0.01).of(345_600.00) }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_ids: [] }

      it { expect(project_consolidation.lead_time_fixed_date.to_f).to eq 0 }
    end
  end

  describe '#lead_time_expedite' do
    include_context 'demands with lead time'

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_ids: Demand.all.map(&:id) }

      it { expect(project_consolidation.lead_time_expedite.to_f).to be_within(0.01).of(14_400.00) }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_ids: [] }

      it { expect(project_consolidation.lead_time_expedite.to_f).to eq 0 }
    end
  end

  describe 'lead_time_range_month' do
    context 'with lead time' do
      let(:consolidation) { Fabricate :project_consolidation, lead_time_min_month: 3, lead_time_max_month: 7 }

      it { expect(consolidation.lead_time_range_month).to eq 4 }
    end

    context 'with no lead time' do
      let(:consolidation) { Fabricate :project_consolidation, lead_time_min_month: nil, lead_time_max_month: nil }

      it { expect(consolidation.lead_time_range_month).to eq 0 }
    end
  end

  describe '#last_data_for_month?' do
    it 'returns true if it is the last data in month' do
      travel_to Time.zone.local(2021, 6, 15, 10, 0, 0) do
        first_consolidation = Fabricate :project_consolidation, consolidation_date: 2.days.ago, last_data_in_month: false
        second_consolidation = Fabricate :project_consolidation, consolidation_date: Time.zone.today, last_data_in_month: false
        third_consolidation = Fabricate :project_consolidation, consolidation_date: 1.day.ago, last_data_in_month: true

        expect(first_consolidation.last_data_for_month?).to be false
        expect(second_consolidation.last_data_for_month?).to be true
        expect(third_consolidation.last_data_for_month?).to be true
      end
    end
  end

  describe '#add_project_throughput_hours' do
    context 'with value defined' do
      it 'adds the hours to the already existent data' do
        project_consolidation = Fabricate :project_consolidation, project_throughput_hours: 10

        project_consolidation.add_project_throughput_hours(15)

        expect(project_consolidation.reload.project_throughput_hours).to eq 25
      end
    end

    context 'with no value defined' do
      it 'adds the hours to the already existent data' do
        project_consolidation = Fabricate :project_consolidation, project_throughput_hours: nil

        project_consolidation.add_project_throughput_hours(15)

        expect(project_consolidation.reload.project_throughput_hours).to eq 15
      end
    end
  end

  describe '#add_project_throughput_hours_in_month' do
    context 'with value defined' do
      it 'adds the hours to the already existent data' do
        project_consolidation = Fabricate :project_consolidation, project_throughput_hours_in_month: 10

        project_consolidation.add_project_throughput_hours_in_month(15)

        expect(project_consolidation.reload.project_throughput_hours_in_month).to eq 25
      end
    end

    context 'with no value defined' do
      it 'adds the hours to the already existent data' do
        project_consolidation = Fabricate :project_consolidation, project_throughput_hours_in_month: nil

        project_consolidation.add_project_throughput_hours_in_month(15)

        expect(project_consolidation.reload.project_throughput_hours_in_month).to eq 15
      end
    end
  end
end
