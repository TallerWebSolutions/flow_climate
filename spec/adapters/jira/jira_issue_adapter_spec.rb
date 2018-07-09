# frozen_string_literal: true

RSpec.describe Jira::JiraIssueAdapter, type: :service do
  let(:company) { Fabricate :company }

  let(:options) { { username: 'foo', password: 'bar', site: 'http://foo.bar', context_path: '/', auth_type: :basic, read_timeout: 120 } }
  let(:client) { JIRA::Client.new(options) }

  let(:jira_account) { Fabricate :jira_account, base_uri: 'http://foo.bar', username: 'foo', password: 'bar' }

  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, customer: customer }

  let!(:first_project) { Fabricate :project, customer: customer, product: product, integration_id: '10000' }

  let!(:first_stage) { Fabricate :stage, company: company, integration_id: '10001', projects: [first_project] }
  let!(:second_stage) { Fabricate :stage, company: company, integration_id: '10003', projects: [first_project] }
  let!(:third_stage) { Fabricate :stage, company: company, integration_id: '10008', projects: [first_project] }

  describe '#process_issue!' do
    context 'when the demand does not exist' do
      context 'having jira account' do
        let!(:jira_account) { Fabricate :jira_account, company: company }
        let!(:responsible_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, demand_field: :responsibles, custom_field_machine_name: 'customfield_10024' }
        let!(:class_of_service_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, demand_field: :class_of_service, custom_field_machine_name: 'customfield_10028' }

        let!(:jira_issue) { client.Issue.build({ id: '10000', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { id: first_project.integration_id }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: '10001', to: '10003', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: '10008', to: '10001', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }

        context 'having project_jira_config' do
          context 'and it is a feature' do
            let!(:project_jira_config) { Fabricate :project_jira_config, project: first_project, jira_account: jira_account }
            it 'creates the demand' do
              Jira::JiraIssueAdapter.instance.process_issue!(jira_issue)
              expect(Demand.count).to eq 1
              expect(Demand.last.assignees_count).to eq 2
              expect(Demand.last.demand_title).to eq 'foo of bar'
              expect(Demand.last).to be_feature
              expect(Demand.last).to be_expedite
              expect(Demand.last.created_date).to eq Time.zone.parse('2018-07-02T11:20:18.998-0300')

              expect(DemandTransition.count).to eq 3

              first_stage_updated = first_stage.reload
              expect(first_stage_updated.demand_transitions.count).to eq 1
              expect(first_stage_updated.demand_transitions.first.last_time_in).to eq Time.zone.parse('2018-07-06T09:40:43.886-0300')
              expect(first_stage_updated.demand_transitions.first.last_time_out).to eq Time.zone.parse('2018-07-08T22:34:47.440-0300')

              second_stage_updated = second_stage.reload
              expect(second_stage_updated.demand_transitions.count).to eq 1
              expect(second_stage_updated.demand_transitions.first.last_time_in).to eq Time.zone.parse('2018-07-08T22:34:47.440-0300')
              expect(second_stage_updated.demand_transitions.first.last_time_out).to be_nil

              third_stage_updated = third_stage.reload
              expect(third_stage_updated.demand_transitions.count).to eq 1
              expect(third_stage_updated.demand_transitions.first.last_time_in).to eq Time.zone.parse('2018-07-02T11:20:18.998-0300')
              expect(third_stage_updated.demand_transitions.first.last_time_out).to eq Time.zone.parse('2018-07-06T09:40:43.886-0300')
            end
          end
          context 'and it is a bug' do
            let!(:jira_issue) { client.Issue.build({ id: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'Bug' }, project: { id: first_project.integration_id }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] } }.with_indifferent_access) }
            let!(:project_jira_config) { Fabricate :project_jira_config, project: first_project, jira_account: jira_account }
            it 'creates the demand' do
              Jira::JiraIssueAdapter.instance.process_issue!(jira_issue)
              expect(Demand.last).to be_bug
            end
          end
          context 'and it is a chore and no class of service' do
            let!(:jira_issue) { client.Issue.build({ id: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'ChoRe' }, project: { id: first_project.integration_id }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] } }.with_indifferent_access) }
            let!(:project_jira_config) { Fabricate :project_jira_config, project: first_project, jira_account: jira_account }
            it 'creates the demand' do
              Jira::JiraIssueAdapter.instance.process_issue!(jira_issue)
              expect(Demand.last).to be_chore
              expect(Demand.last).to be_standard
            end
          end
          context 'and it is a class of service fixed date' do
            let!(:jira_issue) { client.Issue.build({ id: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'fixed date' }, project: { id: first_project.integration_id }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], customfield_10028: { value: 'FixEd DatE' } } }.with_indifferent_access) }
            let!(:project_jira_config) { Fabricate :project_jira_config, project: first_project, jira_account: jira_account }
            it 'creates the demand' do
              Jira::JiraIssueAdapter.instance.process_issue!(jira_issue)
              expect(Demand.last).to be_fixed_date
            end
          end
          context 'and it is a class of service intangible' do
            let!(:jira_issue) { client.Issue.build({ id: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'Chore' }, project: { id: first_project.integration_id }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], customfield_10028: { value: 'intangible' } } }.with_indifferent_access) }
            let!(:project_jira_config) { Fabricate :project_jira_config, project: first_project, jira_account: jira_account }
            it 'creates the demand' do
              Jira::JiraIssueAdapter.instance.process_issue!(jira_issue)
              expect(Demand.last).to be_intangible
            end
          end
          context 'and it is a class of service standard' do
            let!(:jira_issue) { client.Issue.build({ id: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'chore' }, project: { id: first_project.integration_id }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], customfield_10028: { value: 'sTandard' } } }.with_indifferent_access) }
            let!(:project_jira_config) { Fabricate :project_jira_config, project: first_project, jira_account: jira_account }
            it 'creates the demand' do
              Jira::JiraIssueAdapter.instance.process_issue!(jira_issue)
              expect(Demand.last).to be_standard
            end
          end
        end
        context 'having no project_jira_config' do
          it 'does not create the demand' do
            Jira::JiraIssueAdapter.instance.process_issue!(jira_issue)
            expect(Demand.count).to eq 0
          end
        end
      end

      context 'having no jira account' do
        context 'having no project_jira_config' do
          it 'does not create the demand' do
            Jira::JiraIssueAdapter.instance.process_issue!(client.Issue.build)
            expect(Demand.count).to eq 0
          end
        end
      end
    end

    context 'when the demand exists' do
      context 'having jira account' do
        let!(:jira_account) { Fabricate :jira_account, company: company }
        let!(:jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, demand_field: :responsibles, custom_field_machine_name: 'customfield_10024' }
        let!(:jira_issue) { client.Issue.build({ id: '10000', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { id: first_project.integration_id }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: '10001', to: '10003', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: '10008', to: '10001', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }
        let(:demand) { Fabricate :demand, demand_id: '10000' }

        context 'having project_jira_config' do
          let!(:project_jira_config) { Fabricate :project_jira_config, project: first_project, jira_account: jira_account }
          it 'updates the demand' do
            Jira::JiraIssueAdapter.instance.process_issue!(jira_issue)
            expect(Demand.count).to eq 1
            expect(Demand.last.assignees_count).to eq 2
            expect(Demand.last.demand_title).to eq 'foo of bar'
            expect(Demand.last.created_date).to eq Time.zone.parse('2018-07-02T11:20:18.998-0300')
          end
        end
      end
    end
  end
end
