# frozen_string_literal: true

RSpec.describe Jira::JiraIssueAdapter, type: :service do
  let(:company) { Fabricate :company }

  let(:options) { { username: 'foo', password: 'bar', site: 'http://foo.bar', context_path: '/', auth_type: :basic, read_timeout: 120 } }
  let(:client) { JIRA::Client.new(options) }

  let(:jira_account) { Fabricate :jira_account, company: company, base_uri: 'http://foo.bar', username: 'foo', api_token: 'bar' }
  let!(:customer_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :customer, custom_field_machine_name: 'customfield_10013' }

  let(:customer) { Fabricate :customer, company: company, name: 'xpto of bla' }
  let(:other_customer) { Fabricate :customer, company: company, name: 'other_customer' }

  let(:team) { Fabricate :team, company: company }
  let!(:default_member) { Fabricate :team_member, company: company, name: 'default member', jira_account_id: 'default member id' }
  let!(:other_company_member) { Fabricate :team_member, name: 'other default member', jira_account_id: 'other default member id' }

  let!(:default_membership) { Fabricate :membership, team: team, team_member: default_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }
  let!(:other_default_membership) { Fabricate :membership, team: team, team_member: other_company_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }

  let(:product) { Fabricate :product, customer: customer }

  let!(:first_project) { Fabricate :project, company: company, team: team, customers: [customer], products: [product] }

  let!(:backlog) { Fabricate :stage, company: company, teams: [team], integration_id: 'backlog', name: 'backlog', projects: [first_project], order: 0 }

  let!(:first_stage) { Fabricate :stage, company: company, teams: [team], integration_id: 'first_stage', name: 'first_stage', projects: [first_project], order: 1 }
  let!(:second_stage) { Fabricate :stage, company: company, teams: [team], integration_id: 'second_stage', name: 'second_stage', projects: [first_project], order: 2 }
  let!(:third_stage) { Fabricate :stage, company: company, teams: [team], integration_id: 'third_stage', name: 'third_stage', projects: [first_project], order: 3 }

  describe '#process_issue!' do
    context 'when the demand does not exist' do
      let!(:responsible_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :responsibles, custom_field_machine_name: 'customfield_10024' }
      let!(:class_of_service_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :class_of_service, custom_field_machine_name: 'customfield_10028' }

      context 'and it is a feature' do
        let!(:team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'foo', jira_account_id: 'xpto', name: 'team_member' }
        let!(:other_team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'bar', jira_account_id: 'xpto', name: 'other_team_member' }
        let!(:out_team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'xyz', jira_account_id: 'abc', name: 'out_team_member' }
        let!(:other_company_team_member) { Fabricate :team_member, jira_account_user_email: 'bar', jira_account_id: 'sbbrubles' }

        let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }
        let!(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }
        let!(:out_team_member_membership) { Fabricate :membership, team: team, team_member: out_team_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }
        let!(:other_company_membership) { Fabricate :membership, team: team, team_member: other_company_team_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }

        let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, customfield_10013: 'xpto of bla', project: { key: 'foo' }, customfield_10024: [{ emailAddress: 'foo' }, { emailAddress: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', from: 'backlog', to: 'first_stage' }] }, { id: '10038', created: '2018-07-09T09:40:43.886-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10431', created: '2018-07-06T09:10:43.886-0300', items: [{ field: 'Responsible', fieldId: 'customfield_10024', from: nil, fromString: nil, to: "[#{out_team_member.name}, #{team_member.name}, 'foobarxpto']", toString: "[#{out_team_member.name}, #{team_member.name}]" }] }, { id: '10432', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'Responsible', fieldId: 'customfield_10024', from: "[#{team_member.name}, #{out_team_member.name}]", fromString: "[#{team_member.name}, #{out_team_member.name}]", to: "[#{team_member.name}, #{other_team_member.name}]", toString: "[#{team_member.name}, #{other_team_member.name}]" }] }] } }.with_indifferent_access) }

        it 'creates the demand' do
          described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
          expect(Demand.count).to eq 1
          created_demand = Demand.last
          expect(created_demand.project).to eq first_project

          expect(created_demand.team_members).to match_array [out_team_member, team_member, other_team_member]
          expect(created_demand.active_team_members).to match_array [other_team_member]
          expect(created_demand.item_assignments.find_by(team_member: out_team_member).finish_time).not_to be_nil

          expect(created_demand.team).to eq team
          expect(created_demand.product).to eq product
          expect(created_demand.customer).to eq customer
          expect(created_demand.demand_title).to eq 'foo of bar'
          expect(created_demand.downstream_demand?).to be false
          expect(created_demand).to be_feature
          expect(created_demand).to be_expedite
          expect(created_demand.created_date).to eq Time.zone.parse('2018-07-02T11:20:18.998-0300')

          expect(created_demand.demand_transitions.count).to eq 3

          backlog_updated = backlog.reload
          expect(backlog_updated.demand_transitions.count).to eq 1
          expect(backlog_updated.demand_transitions.first.stage).to eq backlog
          expect(backlog_updated.demand_transitions.first.last_time_in).to eq Time.zone.parse('2018-07-02T11:20:18.998-0300')
          expect(backlog_updated.demand_transitions.first.last_time_out).to eq Time.zone.parse('2018-07-08T22:34:47.440-0300')

          first_stage_updated = first_stage.reload
          expect(first_stage_updated.demand_transitions.count).to eq 1
          expect(first_stage_updated.demand_transitions.first.stage).to eq first_stage
          expect(first_stage_updated.demand_transitions.first.last_time_in).to eq Time.zone.parse('2018-07-08T22:34:47.440-0300')
          expect(first_stage_updated.demand_transitions.first.last_time_out).to eq Time.zone.parse('2018-07-09T09:40:43.886-0300')

          second_stage_updated = second_stage.reload
          expect(second_stage_updated.demand_transitions.count).to eq 1
          expect(second_stage_updated.demand_transitions.first.stage).to eq second_stage
          expect(second_stage_updated.demand_transitions.first.last_time_in).to eq Time.zone.parse('2018-07-09T09:40:43.886-0300')
          expect(second_stage_updated.demand_transitions.first.last_time_out).to be_nil

          third_stage_updated = third_stage.reload
          expect(third_stage_updated.demand_transitions.count).to eq 0
        end
      end

      context 'with existent team members' do
        let!(:team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'foo', jira_account_id: 'xpto', name: 'team_member' }
        let!(:other_team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'bar', jira_account_id: 'sbbrubles', name: 'other_team_member' }
        let!(:other_company_team_member) { Fabricate :team_member, jira_account_user_email: 'bar', jira_account_id: 'xpto' }

        let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }
        let!(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }
        let!(:other_company_membership) { Fabricate :membership, team: team, team_member: other_company_team_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }

        let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ accountId: 'xpto', name: team_member.name }, { emailAddress: 'bar' }, { accountId: 'sbbrubles' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }] }, { id: '10432', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'Responsible', fieldId: 'customfield_10024', from: "[#{team_member.name}]", to: "[#{team_member.name}]", toString: "[#{team_member.name}, #{other_team_member.name}]" }] }] } }.with_indifferent_access) }

        it 'creates the demand and adds the members' do
          described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)

          expect(Demand.count).to eq 1
          expect(Demand.last.project).to eq first_project
          expect(Demand.last.customer).to eq customer
          expect(Demand.last.team_members).to match_array [team_member, other_team_member]
          expect(Demand.last.team).to eq team
          expect(Demand.last.demand_title).to eq 'foo of bar'
          expect(Demand.last.downstream_demand?).to be false
          expect(Demand.last).to be_feature
          expect(Demand.last).to be_expedite
          expect(Demand.last.created_date).to eq Time.zone.parse('2018-07-02T11:20:18.998-0300')
        end
      end

      context 'with non existent team members' do
        let!(:team_member) { Fabricate :team_member, company: company, jira_account_user_email: 'foo', jira_account_id: 'xpto', name: 'team_member' }
        let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }

        let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'Bug' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10432', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'Responsible', fieldId: 'customfield_10024', from: "[#{team_member.name}]", to: "['foo do xpto']", toString: "['foo do xpto']" }] }] } }.with_indifferent_access) }

        it 'creates the demand and creates the member' do
          described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
          expect(Demand.last.team_members.size).to eq 1
          expect(Demand.last.team_members).not_to eq team_member
        end
      end

      context 'and it is a chore and no class of service' do
        let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'ChoRe' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] } }.with_indifferent_access) }

        it 'creates the demand as chore as type and standard as class of service' do
          described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
          expect(Demand.last).to be_chore
          expect(Demand.last).to be_standard
        end
      end

      context 'and it is an epic' do
        let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'ePIc' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] } }.with_indifferent_access) }

        it 'creates the demand as chore as type and standard as class of service' do
          described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
          expect(Demand.last).to be_feature
        end
      end

      context 'and it is a class of service fixed date' do
        let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'fixed date' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], customfield_10028: { value: 'FixEd DatE' } } }.with_indifferent_access) }

        it 'creates the demand as fixed date class of service' do
          described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
          expect(Demand.last).to be_fixed_date
        end
      end

      context 'and it is a class of service intangible' do
        context 'reading from custom field machine name (10000)' do
          let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'Chore' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], customfield_10028: { value: 'intangible' } } }.with_indifferent_access) }

          it 'creates the demand as intangible class of service' do
            described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
            expect(Demand.last).to be_intangible
          end
        end

        context 'reading from custom field name' do
          context 'english field' do
            let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10041', created: '2018-07-09T23:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10040', created: '2018-07-09T22:34:47.440-0300', items: [{ field: 'status', from: 'second_stage', to: 'first_stage' }] }, { id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }] }, { id: '10055', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'foo', from: 'third_stage', to: 'first_stage' }] }, { id: '66821', created: '2019-05-08T16:48:41.160-0300', items: [{ field: 'Class of Service (apoio)', fieldtype: 'custom', fieldId: 'customfield_10093', from: '10065', fromString: 'Standard', to: '10064', toString: 'INTangiBle' }] }] } }.with_indifferent_access) }

            it 'creates the demand as intangible class of service' do
              described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
              expect(Demand.last).to be_intangible
            end
          end

          context 'portuguese field' do
            let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10041', created: '2018-07-09T23:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10040', created: '2018-07-09T22:34:47.440-0300', items: [{ field: 'status', from: 'second_stage', to: 'first_stage' }] }, { id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }] }, { id: '10055', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'foo', from: 'third_stage', to: 'first_stage' }] }, { id: '66821', created: '2019-05-08T16:48:41.160-0300', items: [{ field: 'ClassE de ServiçO (apoio)', fieldtype: 'custom', fieldId: 'customfield_10093', from: '10065', fromString: 'Standard', to: '10064', toString: 'INTangiBle' }] }] } }.with_indifferent_access) }

            it 'creates the demand as intangible class of service' do
              described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
              expect(Demand.last).to be_intangible
            end
          end
        end
      end

      context 'and it is a class of service standard' do
        let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'chore' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], customfield_10028: { value: 'sTandard' } } }.with_indifferent_access) }

        it 'creates the demand as standard class of service' do
          described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
          expect(Demand.last).to be_standard
        end
      end

      context 'and it was blocked' do
        context 'with team members as blockers' do
          let!(:team_member) { Fabricate :team_member, company: company, name: 'bla', jira_account_id: 'foo' }
          let!(:other_team_member) { Fabricate :team_member, company: company, name: 'xpto', jira_account_id: 'bar' }

          let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }
          let!(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }

          let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'chore' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], customfield_10028: { value: 'sTandard' }, comment: { comments: [{ created: '2018-07-06T09:40:43.886000000-0300', body: '(flag) comment example', author: { emailAddress: 'bla@bar.com' } }] } }, changelog: { histories: [{ id: '10038', author: { displayName: 'bla', accountId: 'foo' }, created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'Impediment', fromString: '', to: '10055', toString: 'Impediment' }] }, { id: '10055', author: { displayName: 'xpto', accountId: 'bar' }, created: '2018-07-06T13:40:43.886-0300', items: [{ field: 'Impediment', fromString: 'Impediment', to: '10055', toString: '' }] }, { id: '10057', author: { displayName: 'xpto', accountId: 'bar' }, created: '2018-07-09T13:40:43.886-0300', items: [{ field: 'Impediment', fromString: '', to: '10055', toString: 'Impediment' }] }] } }.with_indifferent_access) }

          it 'creates the demand and the blocks information' do
            described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
            demand_created = Demand.last
            expect(demand_created.demand_blocks.count).to eq 2

            first_demand_block = demand_created.demand_blocks.order(created_at: :asc).first
            expect(first_demand_block.blocker).to eq team_member
            expect(first_demand_block.block_reason).to eq '(flag) comment example'
            expect(first_demand_block.block_time).to eq '2018-07-06T09:40:43.886000000-0300'

            expect(first_demand_block.unblocker).to eq other_team_member
            expect(first_demand_block.unblock_time).to eq '2018-07-06T13:40:43.886-0300'

            second_demand_block = demand_created.demand_blocks.second
            expect(second_demand_block.blocker).to eq other_team_member
            expect(second_demand_block.block_time).to eq '2018-07-09T13:40:43.886-0300'

            expect(second_demand_block.unblocker).to be_nil
            expect(second_demand_block.unblock_time).to be_nil

            expect(Demand.last.demand_comments.count).to eq 1
            expect(Demand.last.demand_comments.last.team_member).to be_nil
          end
        end

        context 'with no team members previous created' do
          let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-03T11:20:18.998-0300', issuetype: { name: 'chore' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], customfield_10028: { value: 'sTandard' }, comment: { comments: [{ created: '2018-07-06T09:40:43.886000000-0300', body: '(flag) comment example', author: { emailAddress: 'bla@bar.com' } }] } }, changelog: { histories: [{ id: '10038', author: { displayName: 'bla', accountId: 'foo' }, created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'Impediment', fromString: '', to: '10055', toString: 'Impediment' }] }, { id: '10055', author: { displayName: 'xpto', accountId: 'bar' }, created: '2018-07-06T13:40:43.886-0300', items: [{ field: 'Impediment', fromString: 'Impediment', to: '10055', toString: '' }] }, { id: '10057', author: { displayName: 'xpto', accountId: 'bar' }, created: '2018-07-09T13:40:43.886-0300', items: [{ field: 'Impediment', fromString: '', to: '10055', toString: 'Impediment' }] }] } }.with_indifferent_access) }

          it 'creates the demand and the blocks information' do
            described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
            demand_created = Demand.last
            expect(demand_created.demand_blocks.count).to eq 2

            first_demand_block = demand_created.demand_blocks.order(created_at: :asc).first
            expect(first_demand_block.blocker.memberships.last.team).to eq team
            expect(first_demand_block.blocker.name).to eq 'bla'
            expect(first_demand_block.blocker.memberships.last.start_date).to eq Time.zone.today
            expect(first_demand_block.blocker.memberships.last).to be_developer
            expect(first_demand_block.block_reason).to eq '(flag) comment example'
            expect(first_demand_block.block_time).to eq '2018-07-06T09:40:43.886000000-0300'

            expect(first_demand_block.blocker.memberships.last.team).to eq team
            expect(first_demand_block.unblocker.name).to eq 'xpto'
            expect(first_demand_block.unblocker.memberships.last.start_date).to eq Time.zone.today
            expect(first_demand_block.unblocker.memberships.last).to be_developer
            expect(first_demand_block.unblock_time).to eq '2018-07-06T13:40:43.886-0300'

            second_demand_block = demand_created.demand_blocks.second
            expect(second_demand_block.blocker).to be_a TeamMember
            expect(second_demand_block.block_time).to eq '2018-07-09T13:40:43.886-0300'

            expect(second_demand_block.unblocker).to be_nil
            expect(second_demand_block.unblock_time).to be_nil

            expect(Demand.last.demand_comments.count).to eq 1
            expect(Demand.last.demand_comments.last.team_member).to be_nil
          end
        end
      end

      context 'and the issue returned to a previous stage and went forward again' do
        let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10041', created: '2018-07-09T23:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10040', created: '2018-07-09T22:34:47.440-0300', items: [{ field: 'status', from: 'second_stage', to: 'first_stage' }] }, { id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }] }, { id: '10055', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'foo', from: 'third_stage', to: 'first_stage' }] }] } }.with_indifferent_access) }

        it 'creates the demand and the transitions using the last time it passed in the stage' do
          described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)

          expect(DemandTransition.count).to eq 6

          first_stage_updated = first_stage.reload
          expect(first_stage_updated.demand_transitions.count).to eq 2
          expect(first_stage_updated.demand_transitions.first.last_time_in).to eq Time.zone.parse('2018-07-06T09:40:43.886-0300')
          expect(first_stage_updated.demand_transitions.first.last_time_out).to eq Time.zone.parse('2018-07-08T22:34:47.440-0300')
          expect(first_stage_updated.demand_transitions.second.last_time_in).to eq Time.zone.parse('2018-07-09T22:34:47.440-0300')
          expect(first_stage_updated.demand_transitions.second.last_time_out).to eq Time.zone.parse('2018-07-09T23:34:47.440-0300')

          second_stage_updated = second_stage.reload
          expect(second_stage_updated.demand_transitions.count).to eq 2
          expect(second_stage_updated.demand_transitions.first.last_time_in).to eq Time.zone.parse('2018-07-08T22:34:47.440-0300')
          expect(second_stage_updated.demand_transitions.first.last_time_out).to eq Time.zone.parse('2018-07-09T22:34:47.440-0300')
          expect(second_stage_updated.demand_transitions.second.last_time_in).to eq Time.zone.parse('2018-07-09T23:34:47.440-0300')
          expect(second_stage_updated.demand_transitions.second.last_time_out).to be_nil

          third_stage_updated = third_stage.reload
          expect(third_stage_updated.demand_transitions.count).to eq 1
          expect(third_stage_updated.demand_transitions.first.last_time_in).to eq Time.zone.parse('2018-07-02T11:20:18.998-0300')
          expect(third_stage_updated.demand_transitions.first.last_time_out).to eq Time.zone.parse('2018-07-06T09:40:43.886-0300')
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
          described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
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
          described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
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

        before { described_class.instance.process_issue!(jira_account, product, first_project, jira_issue) }

        it { expect(discarded_demand.reload.discarded_at).to be nil }
      end

      context 'and there is config to the custom responsibles field and the json does not have the field' do
        let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' } }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }

        it 'adds no assignees to demand' do
          described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
          expect(Demand.count).to eq 1
          expect(Demand.last.assignees_count).to eq 0
          expect(Demand.last.demand_title).to eq 'foo of bar'
          expect(Demand.last.downstream_demand?).to be false
          expect(Demand.last.created_date).to eq Time.zone.parse('2018-07-02T11:20:18.998-0300')
        end
      end

      context 'with no transitions' do
        let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, status: { id: backlog.integration_id } }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [] } }.with_indifferent_access) }

        it 'adds the transition to the status using the created date' do
          described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)

          backlog_updated = backlog.reload
          expect(backlog_updated.demand_transitions.count).to eq 1
          expect(backlog_updated.demand_transitions.first.last_time_in).to eq Time.zone.parse('2018-07-02T11:20:18.998-0300')
          expect(backlog_updated.demand_transitions.first.last_time_out).to eq nil
        end
      end

      context 'with no stages either in the team nor in the project' do
        let!(:demand) { Fabricate :demand, external_id: 'xpto do foo' }
        let!(:project) { Fabricate :project, company: company }
        let!(:jira_issue) { client.Issue.build({ key: 'xpto do foo', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10041', created: '2018-07-09T23:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10040', created: '2018-07-09T22:34:47.440-0300', items: [{ field: 'status', from: 'second_stage', to: 'first_stage' }] }, { id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }] }, { id: '10055', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'foo', from: 'third_stage', to: 'first_stage' }] }] } }.with_indifferent_access) }

        it 'creates the demand without the transitions' do
          described_class.instance.process_issue!(jira_account, product, project, jira_issue)
          demand_updated = demand.reload
          expect(demand_updated.demand_transitions).to eq []
        end
      end
    end

    context 'when the product has changed' do
      let!(:demand) { Fabricate :demand, external_id: 'foo' }

      let!(:jira_issue) { client.Issue.build({ key: 'xpto do foo', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10041', created: '2018-07-09T23:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10040', created: '2018-07-09T22:34:47.440-0300', items: [{ field: 'Key', fromString: demand.external_id, to: 'bla' }] }] } }.with_indifferent_access) }

      it 'deletes the previous demand and creates the new one' do
        described_class.instance.process_issue!(jira_account, product, first_project, jira_issue)
        expect(Demand.count).to eq 1
        expect(Demand.first.external_id).to eq 'xpto do foo'
      end
    end
  end
end
