# frozen_string_literal: true

RSpec.describe TasksHelper, type: :helper do
  describe '#projects_for_search_options' do
    let(:company) { Fabricate :company }
    let!(:project) { Fabricate :project, company: company }

    it { expect(helper.projects_for_search_options(company)).to eq(company.projects.order(:name).map { |project| [project.name, project.id] }) }
  end

  describe '#teams_for_search_options' do
    let(:company) { Fabricate :company }
    let!(:team) { Fabricate :team, company: company }

    it { expect(helper.teams_for_search_options(company)).to eq(company.teams.order(:name).map { |team| [team.name, team.id] }) }
  end
end
