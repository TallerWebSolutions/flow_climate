# frozen_string_literal: true

RSpec.describe Flow::CustomerFlowInformation do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, customer: customer }

  describe '#build_financial_burnup' do
    context 'with no demands nor contracts' do
      it 'builds the burnup with the correct information' do
        customer_flow = described_class.new(customer)

        expect(customer_flow.build_financial_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [] }, { name: I18n.t('charts.burnup.current'), data: [] }, { name: I18n.t('charts.burnup.ideal'), data: [] }])
      end
    end

    context 'with no demands but with contracts' do
      it 'builds the burnup with the correct information' do
        Fabricate :contract, customer: customer, total_value: 100
        customer_flow = described_class.new(customer)

        expect(customer_flow.build_financial_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [] }, { name: I18n.t('charts.burnup.current'), data: [] }, { name: I18n.t('charts.burnup.ideal'), data: [] }])
      end
    end

    context 'with demands and contracts' do
      it 'builds the burnup with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          project = Fabricate :project, customers: [customer], products: [product]
          Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, start_date: 3.months.ago, end_date: 1.month.from_now

          3.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30) }
          5.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 1.month.ago, effort_upstream: 40, effort_downstream: 10) }
          2.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 3.months.ago, effort_upstream: 0, effort_downstream: 50) }
          6.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 4.months.ago, effort_upstream: 100, effort_downstream: 300) }

          customer_flow = described_class.new(customer)

          expect(customer_flow.build_financial_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [100_000, 100_000, 100_000, 100_000, 100_000] }, { name: I18n.t('charts.burnup.current'), data: [5000.0, 5000.0, 17_500.0, 23_500.0] }, { name: I18n.t('charts.burnup.ideal'), data: [20_000, 40_000, 60_000, 80_000, 100_000] }])
        end
      end
    end

    context 'with demands and contracts but no effort' do
      context 'with monthly period' do
        it 'builds the burnup with the correct information' do
          travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
            project = Fabricate :project, customers: [customer], products: [product]
            Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, start_date: 3.months.ago, end_date: 1.month.from_now

            3.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: Time.zone.now, effort_upstream: 0, effort_downstream: 0) }
            5.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 1.month.ago, effort_upstream: 0, effort_downstream: 0) }
            2.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 3.months.ago, effort_upstream: 0, effort_downstream: 0) }
            6.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 4.months.ago, effort_upstream: 0, effort_downstream: 0) }

            customer_flow = described_class.new(customer)

            expect(customer_flow.build_financial_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [100_000, 100_000, 100_000, 100_000, 100_000] }, { name: I18n.t('charts.burnup.current'), data: [0, 0, 0, 0] }, { name: I18n.t('charts.burnup.ideal'), data: [20_000, 40_000, 60_000, 80_000, 100_000] }])
          end
        end
      end

      context 'with daily period' do
        it 'builds the burnup with the correct information' do
          travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
            project = Fabricate :project, customers: [customer], products: [product]
            Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, start_date: 3.days.ago, end_date: 1.day.from_now

            3.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30) }
            5.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 1.day.ago, effort_upstream: 40, effort_downstream: 10) }
            2.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 3.days.ago, effort_upstream: 0, effort_downstream: 50) }
            6.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 4.days.ago, effort_upstream: 100, effort_downstream: 300) }

            customer_flow = described_class.new(customer, 'day')

            expect(customer_flow.build_financial_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [100_000, 100_000, 100_000, 100_000, 100_000] }, { name: I18n.t('charts.burnup.current'), data: [0.0, 5000.0, 5000.0, 17_500.0, 23_500.0] }, { name: I18n.t('charts.burnup.ideal'), data: [20_000, 40_000, 60_000, 80_000, 100_000] }])
          end
        end
      end

      context 'with weekly period' do
        it 'builds the burnup with the correct information' do
          travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
            project = Fabricate :project, customers: [customer], products: [product]
            Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, start_date: 3.weeks.ago, end_date: 1.week.from_now

            3.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30) }
            5.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 1.week.ago, effort_upstream: 40, effort_downstream: 10) }
            2.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 3.weeks.ago, effort_upstream: 0, effort_downstream: 50) }
            6.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 4.weeks.ago, effort_upstream: 100, effort_downstream: 300) }

            customer_flow = described_class.new(customer, 'week')

            expect(customer_flow.build_financial_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [100_000, 100_000, 100_000, 100_000, 100_000] }, { name: I18n.t('charts.burnup.current'), data: [5000.0, 5000.0, 17_500.0, 23_500.0] }, { name: I18n.t('charts.burnup.ideal'), data: [20_000, 40_000, 60_000, 80_000, 100_000] }])
          end
        end
      end
    end
  end

  describe '#build_hours_burnup' do
    context 'with no demands nor contracts' do
      it 'builds the burnup with the correct information' do
        customer_flow = described_class.new(customer)

        expect(customer_flow.build_hours_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [] }, { name: I18n.t('charts.burnup.current'), data: [] }, { name: I18n.t('charts.burnup.ideal'), data: [] }])
      end
    end

    context 'with no demands but with contracts' do
      it 'builds the burnup with the correct information' do
        Fabricate :contract, customer: customer, total_value: 100
        customer_flow = described_class.new(customer)

        expect(customer_flow.build_hours_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [] }, { name: I18n.t('charts.burnup.current'), data: [] }, { name: I18n.t('charts.burnup.ideal'), data: [] }])
      end
    end

    context 'with demands and contracts' do
      it 'builds the burnup with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, start_date: 3.months.ago, end_date: 1.month.from_now

          3.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30) }
          5.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 1.month.ago, effort_upstream: 40, effort_downstream: 10) }
          2.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 3.months.ago, effort_upstream: 0, effort_downstream: 50) }
          6.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 4.months.ago, effort_upstream: 100, effort_downstream: 300) }

          customer_flow = described_class.new(customer)

          expect(customer_flow.build_hours_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [2000, 2000, 2000, 2000, 2000] }, { name: I18n.t('charts.burnup.current'), data: [100.0, 100.0, 350.0, 470.0] }, { name: I18n.t('charts.burnup.ideal'), data: [400, 800, 1200, 1600, 2000] }])
        end
      end
    end

    context 'with demands and contracts but no effort' do
      context 'with monthly period' do
        it 'builds the burnup with the correct information' do
          travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
            project = Fabricate :project, customers: [customer], products: [product]
            Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, start_date: 3.months.ago, end_date: 1.month.from_now

            3.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: Time.zone.now, effort_upstream: 0, effort_downstream: 0) }
            5.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 1.month.ago, effort_upstream: 0, effort_downstream: 0) }
            2.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 3.months.ago, effort_upstream: 0, effort_downstream: 0) }
            6.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 4.months.ago, effort_upstream: 0, effort_downstream: 0) }

            customer_flow = described_class.new(customer)

            expect(customer_flow.build_hours_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [2000, 2000, 2000, 2000, 2000] }, { name: I18n.t('charts.burnup.current'), data: [0, 0, 0, 0] }, { name: I18n.t('charts.burnup.ideal'), data: [400, 800, 1200, 1600, 2000] }])
          end
        end
      end

      context 'with daily period' do
        it 'builds the burnup with the correct information' do
          travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
            project = Fabricate :project, customers: [customer], products: [product]
            Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, start_date: 3.days.ago, end_date: 1.day.from_now

            3.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: Time.zone.now, effort_upstream: 0, effort_downstream: 0) }
            5.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 1.day.ago, effort_upstream: 0, effort_downstream: 0) }
            2.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 3.days.ago, effort_upstream: 0, effort_downstream: 0) }
            6.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 4.days.ago, effort_upstream: 0, effort_downstream: 0) }

            customer_flow = described_class.new(customer, 'day')

            expect(customer_flow.build_hours_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [2000, 2000, 2000, 2000, 2000] }, { name: I18n.t('charts.burnup.current'), data: [0, 0, 0, 0, 0] }, { name: I18n.t('charts.burnup.ideal'), data: [400, 800, 1200, 1600, 2000] }])
          end
        end
      end

      context 'with weekly period' do
        it 'builds the burnup with the correct information' do
          travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
            project = Fabricate :project, customers: [customer], products: [product]
            Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, start_date: 3.weeks.ago, end_date: 1.week.from_now

            3.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30) }
            5.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 1.week.ago, effort_upstream: 40, effort_downstream: 10) }
            2.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 3.weeks.ago, effort_upstream: 0, effort_downstream: 50) }
            6.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 4.weeks.ago, effort_upstream: 100, effort_downstream: 300) }

            customer_flow = described_class.new(customer, 'week')

            expect(customer_flow.build_hours_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [2000, 2000, 2000, 2000, 2000] }, { name: I18n.t('charts.burnup.current'), data: [100.0, 100.0, 350.0, 470.0] }, { name: I18n.t('charts.burnup.ideal'), data: [400, 800, 1200, 1600, 2000] }])
          end
        end
      end
    end
  end

  describe '#build_scope_burnup' do
    context 'with no demands' do
      it 'builds the burnup with the correct information' do
        customer_flow = described_class.new(customer)

        expect(customer_flow.build_scope_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [] }, { name: I18n.t('charts.burnup.current'), data: [] }, { name: I18n.t('charts.burnup.ideal'), data: [] }])
      end
    end

    context 'with no demands but with contracts' do
      it 'builds the burnup with the correct information' do
        Fabricate :contract, customer: customer, total_value: 100
        customer_flow = described_class.new(customer)

        expect(customer_flow.build_scope_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [] }, { name: I18n.t('charts.burnup.current'), data: [] }, { name: I18n.t('charts.burnup.ideal'), data: [] }])
      end
    end

    context 'with demands but no contracts' do
      it 'builds the burnup with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]

          3.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30) }
          5.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 1.month.ago, effort_upstream: 40, effort_downstream: 10) }
          2.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 3.months.ago, effort_upstream: 0, effort_downstream: 50) }
          6.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 4.months.ago, effort_upstream: 100, effort_downstream: 300) }

          customer_flow = described_class.new(customer)

          expect(customer_flow.build_scope_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [0] }, { name: I18n.t('charts.burnup.current'), data: [3] }, { name: I18n.t('charts.burnup.ideal'), data: [0] }])
        end
      end
    end

    context 'with demands and contracts' do
      it 'builds the burnup with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

          3.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30) }
          5.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 1.month.ago, effort_upstream: 40, effort_downstream: 10) }
          2.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 3.months.ago, effort_upstream: 0, effort_downstream: 50) }
          6.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 4.months.ago, effort_upstream: 100, effort_downstream: 300) }

          customer_flow = described_class.new(customer)

          expect(customer_flow.build_scope_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [66, 66, 66, 66, 66] }, { name: I18n.t('charts.burnup.current'), data: [2, 2, 7, 10] }, { name: I18n.t('charts.burnup.ideal'), data: [13.2, 26.4, 39.599999999999994, 52.8, 66.0] }])
        end
      end
    end
  end

  describe '#build_quality_info' do
    context 'with no demands' do
      it 'builds the burnup with the correct information' do
        customer_flow = described_class.new(customer)

        expect(customer_flow.build_quality_info).to eq([{ name: I18n.t('charts.quality_info.bugs_by_delivery'), data: [] }])
      end
    end

    context 'with no demands but with contracts' do
      it 'builds the burnup with the correct information' do
        Fabricate :contract, customer: customer, total_value: 100
        customer_flow = described_class.new(customer)

        expect(customer_flow.build_quality_info).to eq([{ name: I18n.t('charts.quality_info.bugs_by_delivery'), data: [] }])
      end
    end

    context 'with demands but no contracts' do
      it 'builds the burnup with the correct information' do
        product = Fabricate :product, customer: customer
        project = Fabricate :project, customers: [customer], products: [product]

        3.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30) }
        5.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 1.month.ago, effort_upstream: 40, effort_downstream: 10) }
        2.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 3.months.ago, effort_upstream: 0, effort_downstream: 50) }
        6.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, end_date: 4.months.ago, effort_upstream: 100, effort_downstream: 300) }

        customer_flow = described_class.new(customer)

        expect(customer_flow.build_quality_info).to eq([{ name: I18n.t('charts.quality_info.bugs_by_delivery'), data: [0] }])
      end
    end

    context 'with demands and contracts' do
      it 'builds the burnup with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

          3.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, demand_type: :feature, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30) }
          5.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, demand_type: :bug, end_date: 1.month.ago, effort_upstream: 40, effort_downstream: 10) }
          2.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, demand_type: :bug, end_date: 3.months.ago, effort_upstream: 0, effort_downstream: 50) }
          6.times { Fabricate(:demand, company: company, product: product, customer: customer, project: project, demand_type: :feature, end_date: 4.months.ago, effort_upstream: 100, effort_downstream: 300) }

          customer_flow = described_class.new(customer)

          expect(customer_flow.build_quality_info).to eq([{ name: I18n.t('charts.quality_info.bugs_by_delivery'), data: [0, 0, 0, 1.4285714285714286] }])
        end
      end
    end
  end
end
