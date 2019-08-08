# frozen_string_literal: true

RSpec.describe DemandBlocksHelper, type: :helper do
  describe '#team_members_options' do
    let(:team_member) { Fabricate :team_member, name: 'zzz' }
    let(:other_team_member) { Fabricate :team_member, name: 'aaa' }

    it { expect(helper.team_members_options(TeamMember.all, team_member.id)).to eq options_for_select(TeamMember.all.order(:name).map { |member| [member.name, member.id] }, team_member.id) }
    it { expect(helper.team_members_options(TeamMember.none, nil)).to eq options_for_select([].map { |member| [member.name, member.id] }, nil) }
  end

  describe '#stage_options' do
    let(:stage) { Fabricate :stage, name: 'zzz' }
    let(:other_stage) { Fabricate :stage, name: 'aaa' }

    it { expect(helper.stage_options(Stage.all, stage.id)).to eq options_for_select(Stage.all.order(:name).map { |stage| [stage.name, stage.id] }, stage.id) }
    it { expect(helper.stage_options(Stage.none, nil)).to eq options_for_select([].map { |stage| [stage.name, stage.id] }, nil) }
  end
end
