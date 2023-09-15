# frozen_string_literal: true

RSpec.describe DemandBlocksHelper do
  describe '#team_members_options' do
    let(:team_member) { Fabricate :team_member, name: 'zzz' }
    let(:other_team_member) { Fabricate :team_member, name: 'aaa' }

    it { expect(helper.team_members_options(TeamMember.all, team_member.id)).to eq options_for_select(TeamMember.order(:name).map { |member| [member.name, member.id] }, team_member.id) }
    it { expect(helper.team_members_options(TeamMember.none, nil)).to eq options_for_select([]) }
  end

  describe '#stage_options' do
    let(:stage) { Fabricate :stage, name: 'zzz' }
    let(:other_stage) { Fabricate :stage, name: 'aaa' }

    it { expect(helper.stage_options(Stage.all, stage.id)).to eq options_for_select(Stage.order(:name).map { |stage| [stage.name, stage.id] }, stage.id) }
    it { expect(helper.stage_options(Stage.none, nil)).to eq options_for_select([]) }
  end

  describe '#project_options' do
    let(:project) { Fabricate :project, name: 'zzz' }
    let(:other_project) { Fabricate :project, name: 'aaa' }

    it { expect(helper.project_options(Project.all, project.id)).to eq options_for_select(Project.order(:name).map { |project| [project.name, project.id] }, project.id) }
    it { expect(helper.project_options(Project.none, nil)).to eq options_for_select([]) }
  end
end
