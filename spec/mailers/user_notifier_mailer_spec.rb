# frozen_string_literal: true

RSpec.describe UserNotifierMailer, type: :mailer do
  describe '#company_weekly_bulletin' do
    let(:first_user) { Fabricate :user, email_notifications: true }
    let(:second_user) { Fabricate :user, email_notifications: true }
    let(:third_user) { Fabricate :user, email_notifications: false }
    let(:fourth_user) { Fabricate :user }

    let!(:company) { Fabricate :company, users: [first_user, second_user, third_user] }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, start_date: Time.zone.today }
    let(:second_project) { Fabricate :project, customer: customer, start_date: Time.zone.today }
    let(:third_project) { Fabricate :project, customer: customer, end_date: Time.zone.today }
    let(:fourth_project) { Fabricate :project, customer: customer, end_date: Time.zone.today }

    let(:first_project_result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago }
    let(:second_project_result) { Fabricate :project_result, project: second_project, result_date: 1.week.ago }
    let(:third_project_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.today }

    let!(:first_demand) { Fabricate :demand, project_result: first_project_result }
    let!(:second_demand) { Fabricate :demand, project_result: first_project_result }
    let!(:third_demand) { Fabricate :demand, project_result: second_project_result }
    let!(:fourth_demand) { Fabricate :demand, project_result: third_project_result }

    subject(:mail) { UserNotifierMailer.company_weekly_bulletin(company, [first_project, second_project], [third_project, fourth_project]).deliver_now }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('projects.portfolio_bulletin.subject')
      expect(mail.to).to match_array [first_user.email, second_user.email]
      expect(mail.from).to eq(['no-reply@taller.net.br'])
      expect(mail.body.encoded).to match first_project.full_name
      expect(mail.body.encoded).to match second_project.full_name
      expect(mail.body.encoded).to match third_project.full_name
      expect(mail.body.encoded).to match fourth_project.full_name
      expect(mail.body.encoded).to match first_demand.demand_id
      expect(mail.body.encoded).to match second_demand.demand_id
    end
  end

  describe '#notify_new_red_alert' do
    let(:first_user) { Fabricate :user, email_notifications: true }
    let(:second_user) { Fabricate :user, email_notifications: true }
    let(:third_user) { Fabricate :user, email_notifications: false }
    let(:fourth_user) { Fabricate :user }

    let!(:company) { Fabricate :company, users: [first_user, second_user, third_user] }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, start_date: Time.zone.today }

    let!(:first_risk_config) { Fabricate :project_risk_config, company: company, risk_type: :no_money_to_deadline, low_yellow_value: 10, high_yellow_value: 30 }
    let(:project_risk_alert) { Fabricate(:project_risk_alert, created_at: Time.zone.today, project: first_project, project_risk_config: first_risk_config, alert_color: :red, alert_value: 30) }

    subject(:mail) { UserNotifierMailer.notify_new_red_alert(first_project, first_risk_config, 'green', 30.0).deliver_now }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('projects.red_alert.subject', project_name: first_project.full_name)
      expect(mail.to).to match_array [first_user.email, second_user.email]
      expect(mail.from).to eq(['no-reply@taller.net.br'])
      expect(mail.body.encoded).to match first_project.full_name
      expect(mail.body.encoded).to match I18n.t("activerecord.attributes.project_risk_config.enums.risk_type.#{first_risk_config.risk_type}")
    end
  end
end
