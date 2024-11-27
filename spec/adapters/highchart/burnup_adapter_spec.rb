# frozen_string_literal: true

RSpec.describe Highchart::BurnupAdapter do
  context 'with data' do
    it 'builds the burnup' do
      travel_to Time.zone.local(2022, 1, 27, 10, 0, 0) do
        first_demand = Fabricate :demand, created_date: 3.weeks.ago, end_date: 2.weeks.ago
        second_demand = Fabricate :demand, created_date: 3.weeks.ago, end_date: 1.week.ago
        third_demand = Fabricate :demand, created_date: 2.weeks.ago, end_date: Time.zone.now
        fourth_demand = Fabricate :demand, created_date: 3.weeks.ago, end_date: nil
        fifth_demand = Fabricate :demand, created_date: 1.week.ago, end_date: Time.zone.now
        discarded_demand = Fabricate :demand, created_date: 3.weeks.ago, end_date: 1.week.ago, discarded_at: 9.days.ago
        other_discarded_demand = Fabricate :demand, created_date: 3.weeks.ago, end_date: 1.week.ago, discarded_at: 2.days.ago

        start_date = 4.weeks.ago
        end_date = 3.weeks.from_now
        burnup = described_class.new(Demand.all, start_date, end_date)

        expect(burnup.work_items).to match_array [first_demand, second_demand, third_demand, fourth_demand, fifth_demand, discarded_demand, other_discarded_demand]
        expect(burnup.x_axis).to eq TimeService.instance.weeks_between_of(start_date.end_of_week, end_date.end_of_week)
        expect(burnup.scope).to eq [0, 5, 6, 6, 5, 5, 5, 5]
        expect(burnup.ideal_burn).to eq [0.625, 1.25, 1.875, 2.5, 3.125, 3.75, 4.375, 5.0]
        expect(burnup.current_burn).to eq [0, 0, 1, 3, 4]
      end
    end
  end
end
