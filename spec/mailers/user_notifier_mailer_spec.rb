# frozen_string_literal: true

RSpec.describe UserNotifierMailer, type: :mailer do
  before { travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) }
  after { travel_back }

  describe '#company_weekly_bulletin' do
    let(:first_user) { Fabricate :user, email_notifications: true }
    let(:second_user) { Fabricate :user, email_notifications: true }
    let(:third_user) { Fabricate :user, email_notifications: false }
    let(:fourth_user) { Fabricate :user }

    let!(:company) { Fabricate :company, users: [first_user, second_user, third_user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }

    let!(:first_project) { Fabricate :project, customer: customer, product: product, status: :executing, start_date: 2.months.ago, end_date: Time.zone.today }
    let!(:second_project) { Fabricate :project, customer: customer, product: product, status: :executing, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:third_project) { Fabricate :project, customer: customer, product: product, status: :executing, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:fourth_project) { Fabricate :project, customer: customer, product: product, status: :executing, start_date: 2.months.ago, end_date: 1.month.from_now }

    let!(:first_demand) { Fabricate :demand, discarded_at: nil, end_date: 1.week.ago }
    let!(:second_demand) { Fabricate :demand, discarded_at: nil, end_date: 1.week.ago }
    let!(:third_demand) { Fabricate :demand }
    let!(:fourth_demand) { Fabricate :demand }

    let!(:red_project) { Fabricate :project, customer: customer, status: :maintenance, end_date: 3.days.from_now, name: 'maintenance_red' }
    let!(:first_alert) { Fabricate :project_risk_alert, project: red_project, alert_color: :red, created_at: Time.zone.now }
    let!(:second_alert) { Fabricate :project_risk_alert, project: red_project, alert_color: :green, created_at: 1.hour.ago }

    let(:other_red_project) { Fabricate :project, customer: customer, status: :executing, end_date: 3.days.from_now, name: 'executing_red' }
    let!(:other_first_alert) { Fabricate :project_risk_alert, project: other_red_project, alert_color: :red, created_at: Time.zone.now }
    let!(:other_second_alert) { Fabricate :project_risk_alert, project: other_red_project, alert_color: :green, created_at: 1.hour.ago }

    subject(:mail) { UserNotifierMailer.company_weekly_bulletin(company.users, company).deliver_now }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('projects.portfolio_bulletin.subject')
      expect(mail.to).to match_array [first_user.email, second_user.email]
      expect(mail.from).to eq(['no-reply@taller.net.br'])
      expect(mail.body.encoded).to match first_project.full_name
      expect(mail.body.encoded).to match second_project.full_name
      expect(mail.body.encoded).to match third_project.full_name
      expect(mail.body.encoded).to match fourth_project.full_name
      expect(mail.body.encoded).to match red_project.full_name
      expect(mail.body.encoded).to match other_red_project.full_name
      expect(mail.body.encoded).to match I18n.t('general.signature.regards')
      expect(mail.body.encoded).to match I18n.t('general.signature.flow_climate_team')
    end
  end

  describe '#notify_new_red_alert' do
    let(:first_user) { Fabricate :user, email_notifications: true }
    let(:second_user) { Fabricate :user, email_notifications: true }
    let(:third_user) { Fabricate :user, email_notifications: false }
    let(:fourth_user) { Fabricate :user }

    let!(:company) { Fabricate :company, users: [first_user, second_user, third_user] }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, start_date: 2.months.ago, end_date: 1.month.from_now }

    let!(:first_risk_config) { Fabricate :project_risk_config, project: first_project, risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 30 }
    let(:project_risk_alert) { Fabricate(:project_risk_alert, created_at: Time.zone.today, project: first_project, project_risk_config: first_risk_config, alert_color: :red, alert_value: 30) }

    subject(:mail) { UserNotifierMailer.notify_new_red_alert(first_project, first_risk_config, 'green', 30.0).deliver_now }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('projects.red_alert.subject', target_name: first_project.full_name)
      expect(mail.to).to match_array [first_user.email, second_user.email]
      expect(mail.from).to eq(['no-reply@taller.net.br'])
      expect(mail.body.encoded).to match first_project.full_name
      expect(mail.body.encoded).to match I18n.t("activerecord.attributes.project_risk_config.enums.risk_type.#{first_risk_config.risk_type}")
      expect(mail.body.encoded).to match I18n.t('general.signature.regards')
      expect(mail.body.encoded).to match I18n.t('general.signature.flow_climate_team')
    end
  end

  describe '#jira_requested_csv' do
    let(:user) { Fabricate :user, email_notifications: true }

    subject(:mail) { UserNotifierMailer.jira_requested_csv(user, 'bla').deliver_now }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('exports.jira_requested_csv.subject')
      expect(mail.body.encoded).to match I18n.t('exports.request_project_information.csv_attached')
      expect(mail.body.encoded).to match I18n.t('general.signature.regards')
      expect(mail.body.encoded).to match I18n.t('general.signature.flow_climate_team')
    end
  end

  describe '#jira_requested_csv' do
    let(:user) { Fabricate :user, email_notifications: true }

    subject(:mail) { UserNotifierMailer.jira_requested_csv(user, 'bla').deliver_now }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('exports.jira_requested_csv.subject')
      expect(mail.body.encoded).to match I18n.t('exports.request_project_information.csv_attached')
      expect(mail.body.encoded).to match I18n.t('general.signature.regards')
      expect(mail.body.encoded).to match I18n.t('general.signature.flow_climate_team')
    end
  end

  describe '#plan_requested' do
    let(:user) { Fabricate :user, admin: true }
    let(:user_plan) { Fabricate :user_plan, user: user }

    subject(:mail) { UserNotifierMailer.plan_requested(user, user_plan).deliver_now }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('plans.request.subject')
    end
  end

  describe '#jira_requested_csv' do
    let(:user) { Fabricate :user, email_notifications: true }

    subject(:mail) { UserNotifierMailer.jira_requested_csv(user, 'bla').deliver_now }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('exports.jira_requested_csv.subject')
      expect(mail.body.encoded).to match I18n.t('exports.request_project_information.csv_attached')
      expect(mail.body.encoded).to match I18n.t('general.signature.regards')
      expect(mail.body.encoded).to match I18n.t('general.signature.flow_climate_team')
    end
  end

  describe '#sync_finished' do
    let(:user) { Fabricate :user, email_notifications: true }

    subject(:mail) { UserNotifierMailer.sync_finished('foo@bla.com.br', 'Foo Bar', 'demand', 'XPTO-100', 1.day.ago, 20.hours.ago, 'http://foo.com.br').deliver_now }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('demands.sync.notification.subject', sync_title: 'demand', object_title: 'XPTO-100')
      expect(mail.body.encoded).to match 'Foo Bar'
      expect(mail.body.encoded).to match 'XPTO-100'
      expect(mail.body.encoded).to match I18n.t('general.signature.regards')
      expect(mail.body.encoded).to match I18n.t('general.signature.flow_climate_team')
    end
  end
end
