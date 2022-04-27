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

    let(:team) { Fabricate :team, company: company, max_work_in_progress: 5 }

    context 'with no user specified' do
      it 'saves the two consolidations and does not send the notification email' do
        # TODO: improve this spec

        base_date = Time.zone.local(2019, 5, 14, 10, 0, 0)

        expect(UserNotifierMailer).not_to(receive(:async_activity_finished))

        first_project = Fabricate :project, customers: [customer], team: team, start_date: base_date - 3.weeks, end_date: base_date.end_of_week, initial_scope: 0, max_work_in_progress: 2
        second_project = Fabricate :project, customers: [customer], team: team, start_date: base_date - 3.weeks, end_date: base_date - 1.week, initial_scope: 0, max_work_in_progress: 3

        Fabricate :demand, project: first_project, team: team, created_date: base_date - 74.days, commitment_date: base_date - 15.days, end_date: base_date - 1.week, effort_downstream: 200, effort_upstream: 10
        Fabricate :demand, project: first_project, team: team, created_date: base_date - 65.days, commitment_date: base_date - 14.days, end_date: base_date - 1.week, effort_downstream: 400, effort_upstream: 130
        Fabricate :demand, project: first_project, team: team, commitment_date: base_date - 10.days, end_date: base_date - 1.week, effort_downstream: 100, effort_upstream: 20

        Fabricate :demand, project: first_project, team: team, commitment_date: base_date - 16.days, end_date: base_date - 2.weeks, effort_downstream: 200, effort_upstream: 10, created_date: base_date - 74.days
        Fabricate :demand, project: first_project, team: team, commitment_date: base_date - 17.days, end_date: base_date - 2.weeks, effort_downstream: 400, effort_upstream: 130, created_date: base_date - 65.days
        Fabricate :demand, project: second_project, team: team, commitment_date: base_date - 2.weeks, end_date: base_date - 2.weeks, effort_downstream: 100, effort_upstream: 20

        3.times { Fabricate :demand, project: first_project, team: team, created_date: base_date - 4.weeks, effort_downstream: 100, effort_upstream: 20 }
        3.times { Fabricate :demand, project: first_project, created_date: base_date - 4.weeks, end_date: nil, effort_downstream: 100, effort_upstream: 20, discarded_at: base_date - 4.weeks }

        travel_to(base_date) { described_class.perform_now(first_project) }
        travel_to(base_date + 1.day) { described_class.perform_now(first_project) }
        travel_to(base_date) { described_class.perform_now(second_project) }

        expect(Consolidations::ProjectConsolidation.count).to eq 3
        expect(first_project.reload.project_consolidations.order(:consolidation_date).last.operational_risk).to eq 1
        expect(first_project.reload.project_consolidations.order(:consolidation_date).last.team_based_operational_risk).to eq 1
        expect(second_project.reload.project_consolidations.order(:consolidation_date).last.operational_risk).to eq 0
        expect(second_project.reload.project_consolidations.order(:consolidation_date).last.team_based_operational_risk).to eq 0
      end
    end

    context 'with specific date' do
      it 'saves de consolidation and sends the notification email' do
        # TODO: improve this spec

        first_project = Fabricate :project, customers: [customer], team: team, start_date: 3.weeks.ago, end_date: Time.zone.today

        described_class.perform_now(first_project, Time.zone.today)

        expect(Consolidations::ProjectConsolidation.count).to eq 1
      end
    end
  end
end
