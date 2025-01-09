# frozen_string_literal: true

RSpec.describe UserNotifierMailer do
  let!(:company) { Fabricate :company, users: [first_user, second_user, third_user] }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, company: company, customer: customer }

  let(:first_user) { Fabricate :user, email_notifications: true }
  let(:second_user) { Fabricate :user, email_notifications: true }
  let(:third_user) { Fabricate :user, email_notifications: false }
  let(:fourth_user) { Fabricate :user }

  describe '#company_weekly_bulletin' do
    context 'with emails to notify' do
      subject(:mail) { described_class.company_weekly_bulletin(company.users, company).deliver_now }

      it 'renders the email' do
        travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) do
          first_project = Fabricate :project, company: company, name: 'first_project', customers: [customer], products: [product], status: :executing, start_date: 2.months.ago, end_date: Time.zone.today
          second_project = Fabricate :project, company: company, name: 'second_project', customers: [customer], products: [product], status: :waiting, start_date: 2.days.from_now, end_date: 1.month.from_now
          third_project = Fabricate :project, company: company, name: 'third_project', customers: [customer], products: [product], status: :waiting, start_date: 4.days.from_now, end_date: 2.months.from_now
          Fabricate :project, company: company, name: 'fourth_project', customers: [customer], products: [product], status: :executing, start_date: 2.months.ago, end_date: 3.months.from_now

          Fabricate :demand, discarded_at: nil, end_date: 1.week.ago
          Fabricate :demand, discarded_at: nil, end_date: 1.week.ago
          Fabricate :demand
          Fabricate :demand

          red_project = Fabricate :project, company: company, customers: [customer], status: :maintenance, start_date: 1.month.ago, end_date: 2.weeks.from_now, name: 'maintenance_red'
          Fabricate :project_risk_alert, project: red_project, alert_color: :red, created_at: Time.zone.now
          Fabricate :project_risk_alert, project: red_project, alert_color: :green, created_at: 1.hour.ago

          other_red_project = Fabricate :project, company: company, customers: [customer], status: :executing, start_date: 1.month.ago, end_date: 1.month.from_now, name: 'executing_red'
          Fabricate :project_risk_alert, project: other_red_project, alert_color: :red, created_at: Time.zone.now
          Fabricate :project_risk_alert, project: other_red_project, alert_color: :green, created_at: 1.hour.ago

          first_risk_config = Fabricate :project_risk_config, project: first_project, risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 30
          Fabricate(:project_risk_alert, created_at: Time.zone.today, project: first_project, project_risk_config: first_risk_config, alert_color: :red, alert_value: 30)

          expect(mail.subject).to eq I18n.t('projects.portfolio_bulletin.subject')
          expect(mail.to).to match_array [first_user.email_address, second_user.email_address]
          expect(mail.from).to eq(['no-reply@taller.net.br'])
          expect(mail.body.encoded).to match first_project.name
          expect(mail.body.encoded).to match second_project.name
          expect(mail.body.encoded).to match third_project.name
          expect(mail.body.encoded).to match red_project.name
          expect(mail.body.encoded).to match other_red_project.name
          expect(mail.body.encoded).to match I18n.t('general.signature.regards')
          expect(mail.body.encoded).to match I18n.t('general.signature.flow_climate_team')
        end
      end
    end

    context 'without emails to notify' do
      subject(:mail) { described_class.company_weekly_bulletin(company.users, company).deliver_now }

      before { User.all.update(email_notifications: false) }

      it { expect(mail).to be_nil }
    end
  end

  describe '#notify_new_red_alert' do
    it 'renders the email' do
      travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) do
        first_project = Fabricate :project, company: company, name: 'first_project', customers: [customer], products: [product], status: :executing, start_date: 2.months.ago, end_date: Time.zone.today

        Fabricate :demand, discarded_at: nil, end_date: 1.week.ago
        Fabricate :demand, discarded_at: nil, end_date: 1.week.ago
        Fabricate :demand
        Fabricate :demand

        red_project = Fabricate :project, company: company, customers: [customer], status: :maintenance, start_date: 1.month.ago, end_date: 2.weeks.from_now, name: 'maintenance_red'
        Fabricate :project_risk_alert, project: red_project, alert_color: :red, created_at: Time.zone.now
        Fabricate :project_risk_alert, project: red_project, alert_color: :green, created_at: 1.hour.ago

        other_red_project = Fabricate :project, company: company, customers: [customer], status: :executing, start_date: 1.month.ago, end_date: 1.month.from_now, name: 'executing_red'
        Fabricate :project_risk_alert, project: other_red_project, alert_color: :red, created_at: Time.zone.now
        Fabricate :project_risk_alert, project: other_red_project, alert_color: :green, created_at: 1.hour.ago

        first_risk_config = Fabricate :project_risk_config, project: first_project, risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 30
        Fabricate(:project_risk_alert, created_at: Time.zone.today, project: first_project, project_risk_config: first_risk_config, alert_color: :red, alert_value: 30)

        mail = described_class.notify_new_red_alert(first_project, first_risk_config, 'green', 30.0).deliver_now

        expect(mail.subject).to eq I18n.t('projects.red_alert.subject', target_name: first_project.name)
        expect(mail.to).to match_array [first_user.email_address, second_user.email_address]
        expect(mail.from).to eq(['no-reply@taller.net.br'])
        expect(mail.body.encoded).to match first_project.name
        expect(mail.body.encoded).to match I18n.t("activerecord.attributes.project_risk_config.enums.risk_type.#{first_risk_config.risk_type}")
        expect(mail.body.encoded).to match I18n.t('general.signature.regards')
        expect(mail.body.encoded).to match I18n.t('general.signature.flow_climate_team')
      end
    end
  end

  describe '#jira_requested_csv' do
    subject(:mail) { described_class.jira_requested_csv(first_user, 'bla').deliver_now }

    it 'renders the email' do
      travel_to Time.zone.local(2018, 11, 19, 10, 0, 0) do
        first_project = Fabricate :project, company: company, name: 'first_project', customers: [customer], products: [product], status: :executing, start_date: 2.months.ago, end_date: Time.zone.today
        Fabricate :project, company: company, name: 'second_project', customers: [customer], products: [product], status: :waiting, start_date: 2.days.from_now, end_date: 1.month.from_now
        Fabricate :project, company: company, name: 'third_project', customers: [customer], products: [product], status: :waiting, start_date: 4.days.from_now, end_date: 2.months.from_now
        Fabricate :project, company: company, name: 'fourth_project', customers: [customer], products: [product], status: :executing, start_date: 2.months.ago, end_date: 3.months.from_now

        Fabricate :demand, discarded_at: nil, end_date: 1.week.ago
        Fabricate :demand, discarded_at: nil, end_date: 1.week.ago
        Fabricate :demand
        Fabricate :demand

        red_project = Fabricate :project, company: company, customers: [customer], status: :maintenance, start_date: 1.month.ago, end_date: 2.weeks.from_now, name: 'maintenance_red'
        Fabricate :project_risk_alert, project: red_project, alert_color: :red, created_at: Time.zone.now
        Fabricate :project_risk_alert, project: red_project, alert_color: :green, created_at: 1.hour.ago

        other_red_project = Fabricate :project, company: company, customers: [customer], status: :executing, start_date: 1.month.ago, end_date: 1.month.from_now, name: 'executing_red'
        Fabricate :project_risk_alert, project: other_red_project, alert_color: :red, created_at: Time.zone.now
        Fabricate :project_risk_alert, project: other_red_project, alert_color: :green, created_at: 1.hour.ago

        first_risk_config = Fabricate :project_risk_config, project: first_project, risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 30
        Fabricate(:project_risk_alert, created_at: Time.zone.today, project: first_project, project_risk_config: first_risk_config, alert_color: :red, alert_value: 30)

        expect(mail.subject).to eq I18n.t('exports.jira_requested_csv.subject')
        expect(mail.body.encoded).to match I18n.t('exports.request_project_information.csv_attached')
        expect(mail.body.encoded).to match I18n.t('general.signature.regards')
        expect(mail.body.encoded).to match I18n.t('general.signature.flow_climate_team')
      end
    end
  end

  describe '#plan_requested' do
    subject(:mail) { described_class.plan_requested(user, user_plan).deliver_now }

    let(:user) { Fabricate :user, admin: true }
    let(:user_plan) { Fabricate :user_plan, user: user }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('plans.request.subject')
    end
  end

  describe '#async_activity_finished' do
    subject(:mail) { described_class.async_activity_finished('foo@bla.com.br', 'Foo Bar', 'demand', 'XPTO-100', 1.day.ago, 20.hours.ago, 'http://foo.com.br').deliver_now }

    let(:user) { Fabricate :user, email_notifications: true }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('async_activity.notification.subject', activity_title: 'demand', object_title: 'XPTO-100')
      expect(mail.body.encoded).to match 'Foo Bar'
      expect(mail.body.encoded).to match 'XPTO-100'
      expect(mail.body.encoded).to match I18n.t('general.signature.regards')
      expect(mail.body.encoded).to match I18n.t('general.signature.flow_climate_team')
    end
  end

  describe '#user_invite_to_customer' do
    subject(:mail) { described_class.user_invite_to_customer('foo@bla.com.br', 'xpto', 'http://foo.com.br').deliver_now }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('user_notifier_mailer.user_invite_to_customer.subject', customer_name: 'xpto')
      expect(mail.body.encoded).to match 'xpto'
      expect(mail.body.encoded).to match 'foo@bla.com.br'
      expect(mail.body.encoded).to match 'http://foo.com.br'
    end
  end

  # test send auth token
  describe '#send_auth_token' do
    subject(:mail) { described_class.send_auth_token(company, 'user@foo.com.br').deliver_now }

    let!(:company) { Fabricate :company, api_token: '1234567890' }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('company.send_auth_token.subject')
      expect(mail.body.encoded).to match I18n.t('company.send_auth_token.message', auth_token: company.api_token)
    end
  end
end
