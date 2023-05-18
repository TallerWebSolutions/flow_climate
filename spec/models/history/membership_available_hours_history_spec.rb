# frozen_string_literal: true

RSpec.describe History::MembershipAvailableHoursHistory do
  describe 'associations' do
    it { is_expected.to belong_to(:membership) }
  end

  describe 'callbacks' do
    describe 'before_save' do
      it 'updates the change_date to the current time' do
        travel_to Time.zone.local(2023, 1, 30, 10, 0, 0) do
          team = Fabricate :team
          team_member = Fabricate :team_member
          membership = Fabricate :membership, team: team, team_member: team_member, end_date: nil
          membership_available_hours_history = Fabricate :membership_available_hours_history, membership: membership

          membership_available_hours_history.save

          expect(membership_available_hours_history.change_date).to eq Time.zone.now
        end
      end
    end
  end
end
