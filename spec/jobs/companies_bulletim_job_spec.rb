# frozen_string_literal: true

RSpec.describe CompaniesBulletimJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued.on_queue('default')
    end
  end

  context 'having projects to collect data' do
    let!(:company) { Fabricate :company }

    let!(:first_user) { Fabricate :user, companies: [company], email_notifications: true }
    let!(:second_user) { Fabricate :user, companies: [company], email_notifications: true }
    let!(:third_user) { Fabricate :user, email_notifications: true }

    let(:customer) { Fabricate :customer, company: company }

    it 'calls the mailer to send the data' do
      travel_to Time.zone.local(2020, 3, 20, 10, 0, 0) do
        Fabricate :project, company: company, customers: [customer], start_date: Time.zone.today, end_date: 2.weeks.from_now
        Fabricate :project, company: company, customers: [customer], start_date: Time.zone.today, end_date: 4.weeks.from_now
        Fabricate :project, company: company, customers: [customer], start_date: 1.month.ago, end_date: Time.zone.today
        Fabricate :project, company: company, customers: [customer], start_date: 2.days.ago, end_date: Time.zone.today

        allow(Time.zone).to receive(:today).and_return Time.zone.today.beginning_of_week + 1.day
        expect(UserNotifierMailer).to receive(:company_weekly_bulletin).with(company.users, company).once
        described_class.perform_now
      end
    end
  end
end
