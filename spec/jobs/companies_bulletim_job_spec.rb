# frozen_string_literal: true

RSpec.describe CompaniesBulletimJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued.on_queue('default')
    end
  end

  context 'having projects to collect data' do
    let(:first_user) { Fabricate :user }
    let(:second_user) { Fabricate :user }
    let(:third_user) { Fabricate :user }

    let!(:company) { Fabricate :company, users: [first_user, second_user] }
    let(:customer) { Fabricate :customer, company: company }

    let!(:first_project) { Fabricate :project, company: company, customers: [customer], start_date: Time.zone.today }
    let!(:second_project) { Fabricate :project, company: company, customers: [customer], start_date: Time.zone.today }
    let!(:third_project) { Fabricate :project, company: company, customers: [customer], end_date: Time.zone.today }
    let!(:fourth_project) { Fabricate :project, company: company, customers: [customer], end_date: Time.zone.today }

    it 'calls the mailer to send the data' do
      allow(Time.zone).to receive(:today).and_return Time.zone.today.beginning_of_week + 1.day
      expect(UserNotifierMailer).to receive(:company_weekly_bulletin).with(company.users, company).once
      described_class.perform_now
    end
  end
end
