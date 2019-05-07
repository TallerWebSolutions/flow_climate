# frozen_string_literal: true

RSpec.describe ProjectConsolidationJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      ProjectConsolidationJob.perform_later
      expect(ProjectConsolidationJob).to have_been_enqueued.on_queue('default')
    end
  end

  context 'having projects to collect data' do
    let(:first_user) { Fabricate :user }

    let!(:company) { Fabricate :company, users: [first_user] }
    let(:customer) { Fabricate :customer, company: company }

    let(:team) { Fabricate :team, company: company }

    let!(:first_project) { Fabricate :project, customer: customer, team: team, start_date: 2.months.ago, end_date: Time.zone.today }
    let!(:second_project) { Fabricate :project, customer: customer, team: team, start_date: 1.month.ago, end_date: Time.zone.tomorrow }

    let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: 3.days.ago, end_date: Time.zone.now, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago }
    let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: 1.day.ago, end_date: Time.zone.now, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago }
    let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: 7.days.ago, end_date: Time.zone.now, effort_downstream: 100, effort_upstream: 20 }

    let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: 7.days.ago, end_date: 7.days.ago, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago }
    let!(:fifth_demand) { Fabricate :demand, project: first_project, commitment_date: 14.days.ago, end_date: 9.days.ago, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago }
    let!(:sixth_demand) { Fabricate :demand, project: second_project, commitment_date: 7.days.ago, end_date: 8.days.ago, effort_downstream: 100, effort_upstream: 20 }

    it 'calls the mailer to send the data' do
      # TODO: improve this spec

      ProjectConsolidationJob.perform_now

      expect(ProjectConsolidation.count).to eq 2
    end
  end
end
