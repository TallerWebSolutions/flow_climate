# frozen_string_literal: true

RSpec.describe UserNotifierMailer, type: :mailer do
  describe '#company_weekly_bulletin' do
    let(:first_user) { Fabricate :user }
    let(:second_user) { Fabricate :user }
    let(:third_user) { Fabricate :user }

    let!(:company) { Fabricate :company, users: [first_user, second_user] }
    let(:customer) { Fabricate :customer }

    let(:first_project) { Fabricate :project, customer: customer, start_date: Time.zone.today }
    let(:second_project) { Fabricate :project, customer: customer, start_date: Time.zone.today }
    let(:third_project) { Fabricate :project, customer: customer, end_date: Time.zone.today }
    let(:fourth_project) { Fabricate :project, customer: customer, end_date: Time.zone.today }

    subject(:mail) { UserNotifierMailer.company_weekly_bulletin(company, [first_project, second_project], [third_project, fourth_project]).deliver_now }

    it 'renders the email' do
      expect(mail.subject).to eq I18n.t('projects.starting_finishing.subject')
      expect(mail.to).to match_array [first_user.email, second_user.email]
      expect(mail.from).to eq(['no-reply@taller.net.br'])
      expect(mail.body.encoded).to match first_project.full_name
      expect(mail.body.encoded).to match second_project.full_name
      expect(mail.body.encoded).to match third_project.full_name
      expect(mail.body.encoded).to match fourth_project.full_name
    end
  end
end
