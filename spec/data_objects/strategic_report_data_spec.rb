RSpec.describe StrategicReportData, type: :service do
  describe '.active_projects_count_per_month' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    context 'having projects' do
      let!(:first_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: Time.zone.today, end_date: Time.zone.today }
      let!(:second_project) { Fabricate :project, customer: customer, status: :executing, start_date: Time.zone.today, end_date: Time.zone.today }
      let!(:third_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 1.month.from_now, end_date: 1.month.from_now }
      let!(:fourth_project) { Fabricate :project, customer: customer, status: :executing, start_date: 1.month.from_now, end_date: 1.month.from_now }
      let!(:fifth_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 2.months.from_now, end_date: 3.months.from_now }
      let!(:sixth_project) { Fabricate :project, customer: customer, status: :waiting, start_date: 2.months.from_now, end_date: 3.months.from_now }
      let!(:seventh_project) { Fabricate :project, customer: customer, status: :finished, start_date: 2.months.from_now, end_date: 3.months.from_now }
      let!(:eighth_project) { Fabricate :project, customer: customer, status: :cancelled, start_date: 2.months.from_now, end_date: 3.months.from_now }

      it 'mounts the data structure to the active project counts in months' do
        strategic_data = StrategicReportData.new(company)
        expect(strategic_data.array_of_months).to eq [[Time.zone.today.month, Time.zone.today.year], [1.month.from_now.to_date.month, 1.month.from_now.to_date.year], [2.months.from_now.to_date.month, 2.months.from_now.to_date.year], [3.months.from_now.to_date.month, 3.months.from_now.to_date.year]]
        expect(strategic_data.active_projects_count_data).to eq [2, 2, 2, 2]
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
