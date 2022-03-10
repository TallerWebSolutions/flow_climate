# frozen_string_literal: true

RSpec.describe TasksHelper, type: :helper do
  describe '#projects_for_search_options' do
    let(:company) { Fabricate :company }
    let!(:project) { Fabricate :project, company: company }

    it { expect(helper.projects_for_search_options(company)).to eq(company.projects.order(:name).map { |project| [project.name, project.id] }) }
  end
end
