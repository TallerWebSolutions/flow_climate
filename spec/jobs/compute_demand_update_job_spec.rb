# frozen_string_literal: true

RSpec.describe ComputeDemandUpdateJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      ComputeDemandUpdateJob.perform_later
      expect(ComputeDemandUpdateJob).to have_been_enqueued.on_queue('default')
    end
  end

  describe '.perform_now' do
    context 'passing a valid demand and a valid team' do
      let(:team) { Fabricate :team }
      let(:demand) { Fabricate :demand }

      it 'calls the mailer to send the data' do
        expect(ProjectResultService.instance).to receive(:compute_demand!).with(team, demand).once
        ComputeDemandUpdateJob.perform_now(team.id, demand.id)
      end
    end
    context 'passing not known team and demand' do
      it 'calls the mailer to send the data' do
        expect(ProjectResultService.instance).to receive(:compute_demand!).never
        ComputeDemandUpdateJob.perform_now('foo', 'bar')
      end
    end
  end
end
