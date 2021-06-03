# frozen_string_literal: true

RSpec.describe Consolidations::ProjectConsolidationJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued.on_queue('consolidations')
    end
  end

  context 'with projects to collect data' do
    let(:first_user) { Fabricate :user }

    let!(:company) { Fabricate :company, users: [first_user] }
    let(:customer) { Fabricate :customer, company: company }

    let(:team) { Fabricate :team, company: company }

    context 'with no user' do
      it 'saves de consolidation and does not send the notification email' do
        # TODO: improve this spec
        travel_to Time.zone.local(2019, 5, 14, 10, 0, 0) do
          first_project = Fabricate :project, customers: [customer], team: team, start_date: 3.weeks.ago, end_date: Time.zone.today
          second_project = Fabricate :project, customers: [customer], team: team, start_date: 3.weeks.ago, end_date: Time.zone.tomorrow

          Fabricate :demand, project: first_project, commitment_date: 15.days.ago, end_date: 1.week.ago, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago
          Fabricate :demand, project: first_project, commitment_date: 14.days.ago, end_date: 1.week.ago, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago
          Fabricate :demand, project: first_project, commitment_date: 10.days.ago, end_date: 1.week.ago, effort_downstream: 100, effort_upstream: 20

          Fabricate :demand, project: first_project, commitment_date: 16.days.ago, end_date: 2.weeks.ago, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago
          Fabricate :demand, project: first_project, commitment_date: 17.days.ago, end_date: 2.weeks.ago, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago
          Fabricate :demand, project: second_project, commitment_date: 2.weeks.ago, end_date: 2.weeks.ago, effort_downstream: 100, effort_upstream: 20

          expect(UserNotifierMailer).not_to(receive(:async_activity_finished))
          described_class.perform_now(first_project)

          expect(Consolidations::ProjectConsolidation.count).to eq 1
        end
      end
    end

    context 'with user' do
      it 'saves de consolidation and sends the notification email' do
        # TODO: improve this spec

        first_project = Fabricate :project, customers: [customer], team: team, start_date: 3.weeks.ago, end_date: Time.zone.today

        described_class.perform_now(first_project, Time.zone.today)

        expect(Consolidations::ProjectConsolidation.count).to eq 1
      end
    end
  end
end
