# frozen_string_literal: true

RSpec.describe CompaniesBulletimJob, type: :active_job do
  before { travel_to Time.zone.local(2020, 3, 20, 10, 0, 0) }

  after { travel_back }

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

    let!(:first_project) { Fabricate :project, company: company, customers: [customer], start_date: Time.zone.today, end_date: 2.weeks.from_now }
    let!(:second_project) { Fabricate :project, company: company, customers: [customer], start_date: Time.zone.today, end_date: 4.weeks.from_now }
    let!(:third_project) { Fabricate :project, company: company, customers: [customer], start_date: 1.month.ago, end_date: Time.zone.today }
    let!(:fourth_project) { Fabricate :project, company: company, customers: [customer], start_date: 2.days.ago, end_date: Time.zone.today }

    it 'calls the mailer to send the data' do
      allow(Time.zone).to receive(:today).and_return Time.zone.today.beginning_of_week + 1.day
      expect(UserNotifierMailer).to receive(:company_weekly_bulletin).with(company.users, company).once
      described_class.perform_now
    end
  end
end
