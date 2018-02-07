# frozen_string_literal: true

RSpec.describe StrategicReportData, type: :service do
  describe '.active_projects_count_per_month' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    context 'having projects' do
      let!(:first_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: Time.zone.today, end_date: Time.zone.today, qty_hours: 1000 }
      let!(:second_project) { Fabricate :project, customer: customer, status: :executing, start_date: Time.zone.today, end_date: Time.zone.today, qty_hours: 500 }
      let!(:third_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 1.month.from_now, end_date: 1.month.from_now, qty_hours: 1500 }
      let!(:fourth_project) { Fabricate :project, customer: customer, status: :executing, start_date: 1.month.from_now, end_date: 1.month.from_now, qty_hours: 700 }
      let!(:fifth_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 200 }
      let!(:sixth_project) { Fabricate :project, customer: customer, status: :waiting, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 5000 }
      let!(:seventh_project) { Fabricate :project, customer: customer, status: :finished, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 8765 }
      let!(:eighth_project) { Fabricate :project, customer: customer, status: :cancelled, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 1232 }

      it 'mounts the data structure to the active project counts in months' do
        strategic_data = StrategicReportData.new(company)
        expect(strategic_data.array_of_months).to eq [[Time.zone.today.month, Time.zone.today.year], [1.month.from_now.to_date.month, 1.month.from_now.to_date.year], [2.months.from_now.to_date.month, 2.months.from_now.to_date.year], [3.months.from_now.to_date.month, 3.months.from_now.to_date.year]]
        expect(strategic_data.active_projects_count_data).to eq [2, 2, 2, 2]
        expect(strategic_data.total_hours_in_month).to eq [45_000.0, 66_000.0, 5032.258064516129, 5032.258064516129]
      end
    end

    context 'having no projects' do
      it 'returns an empty array' do
        strategic_data = StrategicReportData.new(company)
        expect(strategic_data.array_of_months).to eq []
        expect(strategic_data.active_projects_count_data).to eq []
      end
    end
  end
end
