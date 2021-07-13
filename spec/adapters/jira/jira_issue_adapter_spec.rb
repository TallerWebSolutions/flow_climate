# frozen_string_literal: true

RSpec.describe Jira::JiraIssueAdapter, type: :service do
  let(:company) { Fabricate :company }

  let(:options) { { username: 'foo', password: 'bar', site: 'http://foo.bar', context_path: '/', auth_type: :basic } }
  let(:client) { JIRA::Client.new(options) }

  let(:jira_account) { Fabricate :jira_account, company: company, base_uri: 'http://foo.bar', username: 'foo', api_token: 'bar' }
  let!(:customer_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :customer, custom_field_machine_name: 'customfield_10013' }
  let!(:contract_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :contract, custom_field_machine_name: 'customfield_10015' }

  let(:customer) { Fabricate :customer, company: company, name: 'xpto of bla' }
  let(:other_customer) { Fabricate :customer, company: company, name: 'other_customer' }

  let!(:contract) { Fabricate :contract, customer: customer, product: product, start_date: Date.new(2018, 6, 29), end_date: Date.new(2018, 10, 29) }

  let(:team) { Fabricate :team, company: company }
  let!(:default_member) { Fabricate :team_member, company: company, name: 'default member', jira_account_id: 'default member id' }
  let!(:other_company_member) { Fabricate :team_member, name: 'other default member', jira_account_id: 'other default member id' }

  let!(:default_membership) { Fabricate :membership, team: team, team_member: default_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }
  let!(:other_default_membership) { Fabricate :membership, team: team, team_member: other_company_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }

  let(:product) { Fabricate :product, customer: customer }

  let!(:first_project) { Fabricate :project, company: company, team: team, customers: [customer], products: [product] }

  describe '#process_issue' do
    context 'when the demand does not exist' do
      let!(:class_of_service_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :class_of_service, custom_field_machine_name: 'customfield_10028' }

      context 'and it is a feature' do
        let!(:team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'foo', jira_account_id: 'xpto', name: 'team_member' }
        let!(:other_team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'bar', jira_account_id: 'xpto', name: 'other_team_member' }
        let!(:out_team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'xyz', jira_account_id: 'abc', name: 'out_team_member' }
        let!(:other_company_team_member) { Fabricate :team_member, jira_account_user_email: 'bar', jira_account_id: 'sbbrubles' }

        let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }
        let!(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }
        let!(:out_membership) { Fabricate :membership, team: team, team_member: out_team_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }
        let!(:other_company_membership) { Fabricate :membership, team: team, team_member: other_company_team_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }

        let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, customfield_10013: { value: 'xpto of bla' }, customfield_10015: [contract.id], project: { key: 'foo' }, customfield_10024: [{ emailAddress: 'foo' }, { emailAddress: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', created: '2018-07-08T22:34:47.440-0300', author: { displayName: default_member.name }, items: [{ field: 'status', from: 'backlog', to: 'first_stage' }] }, { id: '10038', created: '2018-07-09T09:40:43.886-0300', author: { displayName: default_member.name }, items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10431', created: '2018-07-06T09:10:43.886-0300', author: { displayName: default_member.name }, items: [{ field: 'Responsible', fieldId: 'customfield_10024', from: nil, fromString: nil, to: "[#{out_team_member.name}, #{team_member.name}, 'foobarxpto']", toString: "[#{out_team_member.name}, #{team_member.name}]" }] }, { id: '10432', created: '2018-07-06T09:40:43.886-0300', author: { displayName: default_member.name }, items: [{ field: 'Responsible', fieldId: 'customfield_10024', from: "[#{team_member.name}, #{out_team_member.name}]", fromString: "[#{team_member.name}, #{out_team_member.name}]", to: "[#{team_member.name}, #{other_team_member.name}]", toString: "[#{team_member.name}, #{other_team_member.name}]" }] }] } }.with_indifferent_access) }

        it 'creates the demand' do
          described_class.instance.process_issue(jira_account, jira_issue, product, first_project)
          expect(Demand.count).to eq 1
          created_demand = Demand.last
          expect(created_demand.project).to eq first_project

          expect(created_demand.team).to eq team
          expect(created_demand.product).to eq product
          expect(created_demand.customer).to eq customer
          expect(created_demand.contract).to eq contract
          expect(created_demand.demand_title).to eq 'foo of bar'
          expect(created_demand.downstream_demand?).to be false
          expect(created_demand).to be_feature
          expect(created_demand).to be_expedite
          expect(created_demand.created_date).to eq Time.zone.parse('2018-07-02T11:20:18.998-0300')
        end
      end

      context 'and it is a chore and no class of service' do
        let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'ChoRe' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] } }.with_indifferent_access) }

        it 'creates the demand as chore as type and standard as class of service' do
          described_class.instance.process_issue(jira_account, jira_issue, product, first_project)
          expect(Demand.last).to be_chore
          expect(Demand.last).to be_standard
        end
      end

      context 'and it is an epic' do
        let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'ePIc' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] } }.with_indifferent_access) }

        it 'creates the demand as chore as type and standard as class of service' do
          described_class.instance.process_issue(jira_account, jira_issue, product, first_project)
          expect(Demand.last).to be_feature
        end
      end

      context 'and it is a class of service fixed date' do
        let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'fixed date' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], customfield_10028: { value: 'FixEd DatE' } } }.with_indifferent_access) }

        it 'creates the demand as fixed date class of service' do
          described_class.instance.process_issue(jira_account, jira_issue, product, first_project)
          expect(Demand.last).to be_fixed_date
        end
      end

      context 'and it is a class of service intangible' do
        context 'reading from custom field machine name (10000)' do
          let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'Chore' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], customfield_10028: { value: 'intangible' } } }.with_indifferent_access) }

          it 'creates the demand as intangible class of service' do
            described_class.instance.process_issue(jira_account, jira_issue, product, first_project)
            expect(Demand.last).to be_intangible
          end
        end

        context 'reading from custom field name' do
          context 'english field' do
            let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10041', created: '2018-07-09T23:34:47.440-0300', author: { displayName: default_member.name }, items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10040', created: '2018-07-09T22:34:47.440-0300', author: { displayName: default_member.name }, items: [{ field: 'status', from: 'second_stage', to: 'first_stage' }] }, { id: '10039', created: '2018-07-08T22:34:47.440-0300', author: { displayName: default_member.name }, items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', author: { displayName: default_member.name }, items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }] }, { id: '10055', created: '2018-07-06T09:40:43.886-0300', author: { displayName: default_member.name }, items: [{ field: 'foo', from: 'third_stage', to: 'first_stage' }] }, { id: '66821', created: '2019-05-08T16:48:41.160-0300', author: { displayName: default_member.name }, items: [{ field: 'Class of Service (apoio)', fieldtype: 'custom', fieldId: 'customfield_10093', from: '10065', fromString: 'Standard', to: '10064', toString: 'INTangiBle' }] }] } }.with_indifferent_access) }

            it 'creates the demand as intangible class of service' do
              described_class.instance.process_issue(jira_account, jira_issue, product, first_project)
              expect(Demand.last).to be_intangible
            end
          end

          context 'portuguese field' do
            let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10041', created: '2018-07-09T23:34:47.440-0300', author: { displayName: default_member.name }, items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10040', created: '2018-07-09T22:34:47.440-0300', author: { displayName: default_member.name }, items: [{ field: 'status', from: 'second_stage', to: 'first_stage' }] }, { id: '10039', created: '2018-07-08T22:34:47.440-0300', author: { displayName: default_member.name }, items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', author: { displayName: default_member.name }, items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }] }, { id: '10055', created: '2018-07-06T09:40:43.886-0300', author: { displayName: default_member.name }, items: [{ field: 'foo', from: 'third_stage', to: 'first_stage' }] }, { id: '66821', created: '2019-05-08T16:48:41.160-0300', author: { displayName: default_member.name }, items: [{ field: 'ClassE de ServiçO (apoio)', fieldtype: 'custom', fieldId: 'customfield_10093', from: '10065', fromString: 'Standard', to: '10064', toString: 'INTangiBle' }] }] } }.with_indifferent_access) }

            it 'creates the demand as intangible class of service' do
              described_class.instance.process_issue(jira_account, jira_issue, product, first_project)
              expect(Demand.last).to be_intangible
            end
          end
        end
      end

      context 'and it is a class of service standard' do
        let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'chore' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], customfield_10028: { value: 'sTandard' } } }.with_indifferent_access) }

        it 'creates the demand as standard class of service' do
          described_class.instance.process_issue(jira_account, jira_issue, product, first_project)
          expect(Demand.last).to be_standard
        end
      end
    end

    context 'when the demand exists' do
      let!(:jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :responsibles, custom_field_machine_name: 'customfield_10024' }
      let!(:demand) { Fabricate :demand, company: company, project: first_project, team: team, external_id: '10000' }
      let!(:second_project) { Fabricate :project, company: company, team: team, customers: [customer, other_customer], products: [product] }
      let!(:jira_project_config) { Fabricate :jira_project_config, jira_product_config: jira_product_config, project: second_project, fix_version_name: 'bar' }

      let!(:team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'foo', jira_account_id: 'bar', name: 'team_member' }
      let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }

      let!(:jira_product_config) { Fabricate :jira_product_config, product: product, jira_product_key: 'foo' }

      let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], comment: { comments: [{ created: Time.zone.local(2019, 5, 27, 10, 0, 0).iso8601, body: 'comment example', author: { emailAddress: team_member.jira_account_user_email, displayName: team_member.name, accountId: team_member.jira_account_id } }] }, fixVersions: [{ name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }

      context 'and the demand is not archived' do
        it 'updates the demand' do
          described_class.instance.process_issue(jira_account, jira_issue, product, first_project)
          expect(Demand.count).to eq 1
          expect(Demand.last.project).to eq second_project
          expect(Demand.last.customer).to be_nil
          expect(Demand.last.assignees_count).to eq 0
          expect(Demand.last.demand_title).to eq 'foo of bar'
          expect(Demand.last.downstream_demand?).to be false
          expect(Demand.last.demand_comments.first.comment_text).to eq 'comment example'
          expect(Demand.last.demand_comments.first.comment_date).to eq Time.zone.local(2019, 5, 27, 10, 0, 0)
          expect(Demand.last.demand_comments.first.team_member).to eq team_member
          expect(Demand.last.external_url).to eq "#{jira_account.base_uri}browse/10000"
          expect(Demand.last.created_date).to eq Time.zone.parse('2018-07-02T11:20:18.998-0300')
        end
      end

      context 'and the demand was archived' do
        let!(:archived_stage) { Fabricate :stage, stage_type: :archived, projects: [first_project] }
        let!(:archived_demand_transition) { Fabricate :demand_transition, stage: archived_stage, demand: demand }

        it 'updates the demand' do
          described_class.instance.process_issue(jira_account, jira_issue, product, first_project)
          expect(Demand.count).to eq 1
          expect(Demand.last.assignees_count).to eq 0
          expect(Demand.last.demand_title).to eq 'foo of bar'
          expect(Demand.last.downstream_demand?).to be false
          expect(Demand.last.external_url).to eq "#{jira_account.base_uri}browse/10000"
          expect(Demand.last.created_date).to eq Time.zone.parse('2018-07-02T11:20:18.998-0300')
        end
      end

      context 'and the demand was discarded' do
        let!(:discarded_demand) { Fabricate :demand, company: company, project: first_project, external_id: '10010', discarded_at: Time.zone.yesterday }
        let!(:jira_issue) { client.Issue.build({ key: '10010', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' } }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }

        before { described_class.instance.process_issue(jira_account, jira_issue, product, first_project) }

        it { expect(discarded_demand.reload.discarded_at).to be nil }
      end
    end

    context 'when the product has changed' do
      let!(:demand) { Fabricate :demand, external_id: 'foo' }

      let!(:jira_issue) { client.Issue.build({ key: 'xpto do foo', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10041', created: '2018-07-09T23:34:47.440-0300', author: { displayName: default_member.name }, items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10040', created: '2018-07-09T22:34:47.440-0300', author: { displayName: default_member.name }, items: [{ field: 'Key', fromString: demand.external_id, to: 'bla' }] }] } }.with_indifferent_access) }

      it 'deletes the previous demand and creates the new one' do
        described_class.instance.process_issue(jira_account, jira_issue, product, first_project)
        expect(Demand.count).to eq 1
        expect(Demand.first.external_id).to eq 'xpto do foo'
      end
    end
  end

  describe '#process_jira_issue_changelog' do
    let!(:team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'foo', jira_account_id: 'xpto', name: 'team_member' }

    context 'when reading responsibles assignments' do
      context 'when there is a custom field registered' do
        let!(:responsible_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :responsibles, custom_field_machine_name: 'customfield_10029' }

        context 'and the members already exist' do
          let(:demand) { Fabricate :demand, company: company, team: team, external_id: 'CRE-726' }
          let!(:other_team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'bar', jira_account_id: 'sbbrubles', name: 'other_team_member' }
          let!(:other_company_team_member) { Fabricate :team_member, jira_account_user_email: 'bar', jira_account_id: 'xpto' }

          let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }
          let!(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }
          let!(:other_company_membership) { Fabricate :membership, team: team, team_member: other_company_team_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }

          let!(:jira_issue_changelog) { file_fixture('issue_changelog_paginated_page_one.json').read }

          it 'adds the members' do
            described_class.instance.process_jira_issue_changelog(jira_account, JSON.parse(jira_issue_changelog), demand, team_member)

            updated_demand = Demand.last
            expect(updated_demand.memberships).to match_array [membership, other_membership]
            expect(updated_demand.item_assignments.open_assignments).to eq []
          end
        end

        context 'when the members do not exist yet' do
          let(:demand) { Fabricate :demand, company: company, team: team, external_id: 'CRE-726' }
          let!(:team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'foo', jira_account_id: 'xpto', name: 'team_member' }
          let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }

          let!(:jira_issue_changelog) { file_fixture('issue_changelog_paginated_page_one.json').read }

          it 'creates the members' do
            expect(DemandEffortService.instance).to(receive(:build_efforts_to_demand)).once.with(demand)
            described_class.instance.process_jira_issue_changelog(jira_account, JSON.parse(jira_issue_changelog), demand, team_member)
            expect(Demand.last.memberships.size).to eq 2
            expect(Demand.last.memberships.map(&:team_member_name)).to match_array %w[team_member other_team_member]
          end
        end
      end

      context 'when there no custom field registered' do
        let(:demand) { Fabricate :demand, company: company, team: team, external_id: 'CRE-726' }
        let!(:team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'foo', jira_account_id: 'xpto', name: 'team_member' }
        let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }

        let!(:jira_issue_changelog) { file_fixture('issue_changelog_paginated_page_one.json').read }

        it 'does not create the responsibles' do
          described_class.instance.process_jira_issue_changelog(jira_account, JSON.parse(jira_issue_changelog), demand, team_member)
          expect(Demand.last.memberships.size).to eq 0
        end
      end
    end

    context 'when reading transitions' do
      let!(:creator) { Fabricate :team_member, company: company, jira_account_user_email: 'foo', jira_account_id: 'xpto', name: 'creator' }

      let!(:first_stage) { Fabricate :stage, company: company, teams: [team], integration_id: '1', name: 'Backlog', projects: [first_project], order: 1 }
      let!(:second_stage) { Fabricate :stage, company: company, teams: [team], integration_id: '10031', name: 'Design', projects: [first_project], order: 2 }
      let!(:third_stage) { Fabricate :stage, company: company, teams: [team], integration_id: '10012', name: 'Ready to Business Analysis', projects: [first_project], order: 3 }
      let!(:fourth_stage) { Fabricate :stage, company: company, teams: [team], integration_id: '10013', name: 'Business Analysis', projects: [first_project], order: 4 }

      let(:demand) { Fabricate :demand, company: company, team: team, project: first_project, external_id: 'CRE-726', created_date: '2020-07-31T09:11:27.525901000-0300' }
      let!(:jira_issue_changelog) { file_fixture('issue_changelog_paginated_page_one.json').read }

      context 'when there is no transitions created yet' do
        it 'creates the transitions' do
          expect(Slack::SlackNotificationService.instance).to receive(:notify_demand_state_changed).exactly(11).times

          described_class.instance.process_jira_issue_changelog(jira_account, JSON.parse(jira_issue_changelog), demand, creator)

          expect(Demand.last.demand_transitions.size).to eq 12
          expect(Demand.last.demand_transitions.order(:last_time_in).map(&:stage_name)).to eq ['Backlog', 'Design', 'Ready to Business Analysis', 'Design', 'Backlog', 'Design', 'Ready to Business Analysis', 'Design', 'Ready to Business Analysis', 'Business Analysis', 'Ready to Business Analysis', 'Business Analysis']
          expect(Demand.last.demand_transitions.order(:last_time_in).map { |t| t.team_member&.name }).to eq %w[creator team_member team_member team_member team_member other_team_member other_team_member other_team_member other_team_member other_team_member other_team_member other_team_member]
          expect(Demand.last.demand_transitions.order(:last_time_in).map(&:last_time_in).map(&:iso8601)).to eq %w[2020-07-31T09:11:27-03:00 2020-08-24T15:27:23-03:00 2020-08-25T09:45:35-03:00 2020-08-27T11:47:44-03:00 2020-08-27T11:47:46-03:00 2021-03-25T09:48:51-03:00 2021-03-26T12:52:57-03:00 2021-04-01T10:50:54-03:00 2021-04-01T14:19:48-03:00 2021-04-06T14:33:08-03:00 2021-04-06T16:22:39-03:00 2021-04-06T16:32:53-03:00]
          expect(Demand.last.demand_transitions.order(:last_time_in).map(&:last_time_out).map { |last_time_out| last_time_out&.iso8601 }).to eq ['2020-08-24T15:27:23-03:00', '2020-08-25T09:45:35-03:00', '2020-08-27T11:47:44-03:00', '2020-08-27T11:47:46-03:00', '2021-03-25T09:48:51-03:00', '2021-03-26T12:52:57-03:00', '2021-04-01T10:50:54-03:00', '2021-04-01T14:19:48-03:00', '2021-04-06T14:33:08-03:00', '2021-04-06T16:22:39-03:00', '2021-04-06T16:32:53-03:00', nil]
        end
      end

      context 'when it has transitions already' do
        it 'creates the transitions' do
          # create all transitions
          described_class.instance.process_jira_issue_changelog(jira_account, JSON.parse(jira_issue_changelog), demand, creator)
          expect(Demand.last.demand_transitions.size).to eq 12

          # try to duplicate transitions
          described_class.instance.process_jira_issue_changelog(jira_account, JSON.parse(jira_issue_changelog), demand, creator)

          expect(Demand.last.demand_transitions.size).to eq 12
          expect(Demand.last.demand_transitions.order(:last_time_in).map(&:stage_name)).to eq ['Backlog', 'Design', 'Ready to Business Analysis', 'Design', 'Backlog', 'Design', 'Ready to Business Analysis', 'Design', 'Ready to Business Analysis', 'Business Analysis', 'Ready to Business Analysis', 'Business Analysis']
          expect(Demand.last.demand_transitions.order(:last_time_in).map(&:last_time_in).map(&:iso8601)).to eq %w[2020-07-31T09:11:27-03:00 2020-08-24T15:27:23-03:00 2020-08-25T09:45:35-03:00 2020-08-27T11:47:44-03:00 2020-08-27T11:47:46-03:00 2021-03-25T09:48:51-03:00 2021-03-26T12:52:57-03:00 2021-04-01T10:50:54-03:00 2021-04-01T14:19:48-03:00 2021-04-06T14:33:08-03:00 2021-04-06T16:22:39-03:00 2021-04-06T16:32:53-03:00]
          expect(Demand.last.demand_transitions.order(:last_time_in).map(&:last_time_out).map { |last_time_out| last_time_out&.iso8601 }).to eq ['2020-08-24T15:27:23-03:00', '2020-08-25T09:45:35-03:00', '2020-08-27T11:47:44-03:00', '2020-08-27T11:47:46-03:00', '2021-03-25T09:48:51-03:00', '2021-03-26T12:52:57-03:00', '2021-04-01T10:50:54-03:00', '2021-04-01T14:19:48-03:00', '2021-04-06T14:33:08-03:00', '2021-04-06T16:22:39-03:00', '2021-04-06T16:32:53-03:00', nil]
        end
      end

      context 'when there were errors' do
        let(:demand) { Fabricate :demand, company: company, team: team, project: first_project, external_id: 'CRE-726', created_date: '2020-07-31T09:11:27.525901000-0300' }
        let!(:jira_issue_changelog) { file_fixture('issue_changelog_paginated_page_one.json').read }

        context 'in demand transition from saving' do
          it 'saves a Jira integration error' do
            double_transitions = instance_double('ActiveRecord::Relation')
            allow(DemandTransition).to(receive(:where)).and_return(double_transitions)
            allow(double_transitions).to receive(:first_or_create).and_raise(ActiveRecord::RecordNotUnique)
            described_class.instance.process_jira_issue_changelog(jira_account, JSON.parse(jira_issue_changelog), demand, creator)

            expect(Jira::JiraApiError.count).not_to eq 0
          end
        end

        context 'in demand transition to saving' do
          it 'saves a Jira integration error' do
            allow_any_instance_of(DemandTransition).to receive(:update).and_raise(ActiveRecord::RecordNotUnique)
            described_class.instance.process_jira_issue_changelog(jira_account, JSON.parse(jira_issue_changelog), demand, creator)

            expect(Jira::JiraApiError.count).not_to eq 0
          end
        end

        context 'in demand transition to saving slack ArgumentError' do
          it 'registers the error in the logger and does not halt the demana' do
            allow_any_instance_of(Slack::SlackNotificationService).to receive(:notify_demand_state_changed).and_raise(ArgumentError)
            expect(Rails.logger).to(receive(:error)).exactly(11).times

            described_class.instance.process_jira_issue_changelog(jira_account, JSON.parse(jira_issue_changelog), demand, creator)
          end
        end
      end
    end

    context 'when reading blocks and portfolio unit' do
      let(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'Pre-paid Virtual Card' }
      let!(:jira_portfolio_unit_config) { Fabricate :jira_portfolio_unit_config, portfolio_unit: portfolio_unit, jira_field_name: 'customfield_10052' }

      let!(:jira_issue) { client.Issue.build({ key: 'EBANX-2', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'chore' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], customfield_10028: { value: 'sTandard' }, customfield_10052: portfolio_unit.name, comment: { comments: [{ created: '2021-04-19 14:46:59.437000000 -0300', body: '(flag) comment example', author: { displayName: 'team_member' } }] } }, changelog: { histories: [{ id: '10038', author: { displayName: 'bla', accountId: 'foo' }, created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'Impediment', fromString: '', to: '10055', toString: 'Impediment' }] }, { id: '10055', author: { displayName: 'xpto', accountId: 'bar' }, created: '2018-07-06T13:40:43.886-0300', items: [{ field: 'Impediment', fromString: 'Impediment', to: '10055', toString: '' }] }, { id: '10057', author: { displayName: 'xpto', accountId: 'bar' }, created: '2018-07-09T13:40:43.886-0300', items: [{ field: 'Impediment', fromString: '', to: '10055', toString: 'Impediment' }] }] } }.with_indifferent_access) }
      let!(:jira_issue_changelog) { file_fixture('issue_changelog_with_blocks.json').read }
      let!(:creator) { Fabricate :team_member, company: company, jira_account_user_email: 'foo', jira_account_id: 'xpto', name: 'creator' }
      let!(:demand) { Fabricate :demand, company: company, team: team, product: product, external_id: 'EBANX-2' }

      context 'and there is a specified reason' do
        it 'creates the blocks information' do
          described_class.instance.process_issue(jira_account, jira_issue, product, first_project)
          described_class.instance.process_jira_issue_changelog(jira_account, JSON.parse(jira_issue_changelog), demand, creator)

          demand_updated = demand.reload
          expect(demand_updated.demand_blocks.count).to eq 2
          expect(demand_updated.portfolio_unit).to eq portfolio_unit

          first_demand_block = demand_updated.demand_blocks.order(created_at: :asc).first
          expect(first_demand_block.block_time).to eq '2021-04-19 14:46:59.437000000 -0300'
          expect(first_demand_block.blocker.memberships.last.team).to eq team
          expect(first_demand_block.blocker.name).to eq 'team_member'
          expect(first_demand_block.blocker.memberships.last.start_date).to eq Time.zone.today
          expect(first_demand_block.blocker.memberships.last).to be_developer
          expect(first_demand_block.block_reason).to eq '(flag) comment example'

          expect(first_demand_block.blocker.memberships.last.team).to eq team
          expect(first_demand_block.unblocker.name).to eq 'team_member'
          expect(first_demand_block.unblocker.memberships.last.start_date).to eq Time.zone.today
          expect(first_demand_block.unblocker.memberships.last).to be_developer
          expect(first_demand_block.unblock_time).to eq '2021-04-19 15:29:07.219000000 -0300'

          second_demand_block = demand_updated.demand_blocks.second
          expect(second_demand_block.blocker).to be_a TeamMember
          expect(second_demand_block.block_time).to eq '2021-04-19 17:51:20.104000000 -0300'

          expect(second_demand_block.unblocker).to be_nil
          expect(second_demand_block.unblock_time).to be_nil
        end
      end

      context 'and there is no reason specified but it was already specified in FC' do
        it 'keeps the manual added reason' do
          # we will not read the comments so the algorithm will not get a reason in the reading process
          demand_block = Fabricate :demand_block, demand: demand, block_time: '2021-04-19 17:51:20.104000000 -0300', block_reason: 'xpto'
          described_class.instance.process_jira_issue_changelog(jira_account, JSON.parse(jira_issue_changelog), demand, creator)

          expect(demand_block.reload.block_reason).to eq 'xpto'
        end
      end
    end
  end
end
