# frozen_string_literal: true

RSpec.describe ProjectResultService, type: :service do
  describe '#compute_demand!' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:previous_team) { Fabricate :team, company: company }
    let!(:previous_team_member) { Fabricate :team_member, team: previous_team, total_monthly_payment: 200, hours_per_month: 40 }

    let(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, team: team, total_monthly_payment: 100, hours_per_month: 40 }
    let!(:other_team_member) { Fabricate :team_member, team: team, total_monthly_payment: 300, hours_per_month: 50 }

    let(:product) { Fabricate :product, customer: customer, team: previous_team }
    let(:project) { Fabricate :project, product: product, customer: customer, initial_scope: 10, start_date: 1.week.ago, end_date: 1.week.from_now }

    let(:existent_project_result) { Fabricate :project_result, project: project }
    let(:other_existent_project_result) { Fabricate :project_result }

    context 'when the demand has no previous result' do
      context 'dealing with valid project result' do
        context 'and no end_date' do
          let!(:demand) { Fabricate :demand, project: project, project_result: nil, created_date: 2.days.ago, end_date: nil }

          it 'creates the new project result to the demand using the create date' do
            existent_results = double([existent_project_result, other_existent_project_result])
            double_empty_result = ProjectResult.none

            allow(ProjectResult).to(receive(:where).with(team: team, project: project, result_date: 2.days.ago.to_date) { double_empty_result })
            allow(double_empty_result).to(receive(:first_or_create) { ProjectResult.new(team: team, project: project, result_date: 2.days.ago.to_date) })

            expect(ProjectResult).to(receive(:where).with('result_date >= :new_result_date', new_result_date: 2.days.ago.to_date).once { existent_results })
            expect(existent_results).to receive(:map).and_yield(existent_project_result).and_yield(other_existent_project_result)

            expect(existent_project_result).to receive(:compute_flow_metrics!).once
            expect(other_existent_project_result).to receive(:compute_flow_metrics!).once
            expect(ProjectResult).to receive(:reset_counters).once

            ProjectResultService.instance.compute_demand!(team, demand)

            project_result = ProjectResult.last
            expect(project_result.demands).to eq [demand]
            expect(project_result.team).to eq team
            expect(project_result.result_date).to eq 2.days.ago.to_date
            expect(project_result.cost_in_month).to eq 0
            expect(project_result.available_hours.to_f).to eq 3.0
            expect(project_result.throughput_upstream).to eq 0
            expect(project_result.throughput_downstream).to eq 0
            expect(project_result.known_scope).to eq 11
            expect(project_result.qty_hours_upstream).to eq 0
            expect(project_result.qty_hours_downstream).to eq 0
            expect(project_result.qty_hours_bug).to eq 0
            expect(project_result.qty_bugs_closed).to eq 0
            expect(project_result.remaining_days).to eq 10

            expect(product.reload.team).to eq team
          end
        end
        context 'and having an end_date' do
          let!(:demand) { Fabricate :demand, project: project, project_result: nil, created_date: 2.days.ago, end_date: 1.day.from_now, effort_upstream: 0, effort_downstream: 20 }

          it 'creates the new project result to the demand using the end date' do
            ProjectResultService.instance.compute_demand!(team, demand)
            project_result = ProjectResult.last
            expect(project_result.demands).to eq [demand]
            expect(project_result.result_date).to eq 1.day.from_now.to_date
            expect(project_result.cost_in_month).to eq 200
            expect(project_result.available_hours.to_f).to eq 3.0
            expect(project_result.throughput_upstream).to eq 0
            expect(project_result.throughput_downstream).to eq 1
            expect(project_result.known_scope).to eq 11
            expect(project_result.qty_hours_upstream).to eq 0
            expect(project_result.qty_hours_downstream).to eq 20
            expect(project_result.qty_hours_bug).to eq 0
            expect(project_result.qty_bugs_closed).to eq 0
            expect(project_result.remaining_days).to eq 7

            expect(product.reload.team).to eq team
          end
        end
      end
      context 'when the demand has a previous result' do
        context 'and the result is in another date' do
          let!(:first_project_result) { Fabricate :project_result, team: team, project: project, result_date: 4.days.ago }
          let!(:previous_project_result) { Fabricate :project_result, team: team, project: project, result_date: 3.days.ago }
          let!(:project_result) { Fabricate :project_result, team: team, project: project, result_date: 2.days.ago, cost_in_month: team.active_monthly_cost_for_billable_types([project.project_type]), available_hours: team.active_monthly_available_hours_for_billable_types([project.project_type]) }
          let!(:after_project_result) { Fabricate :project_result, team: team, project: project, result_date: Time.zone.tomorrow, known_scope: 100 }

          context 'and has only the processed demand' do
            let(:demand) { Fabricate :demand, project: project, project_result: previous_project_result, created_date: 1.day.ago, end_date: Time.zone.today }

            it 'changes the project result to the new date and deletes the previous result' do
              ProjectResultService.instance.compute_demand!(team, demand)
              new_project_result = demand.reload.project_result
              expect(new_project_result.id).not_to eq project_result.id
              expect(new_project_result.result_date).to eq Time.zone.today
              expect(new_project_result.demands).to eq [demand]
              expect(new_project_result.qty_hours_downstream).to eq demand.effort_downstream
              expect(new_project_result.qty_hours_upstream).to eq demand.effort_upstream
              expect(new_project_result.known_scope).to eq 11

              expect(ProjectResult.find_by(id: first_project_result.id)).to eq first_project_result

              expect(ProjectResult.find_by(id: previous_project_result.id)).to be_nil

              before_project_result = ProjectResult.find_by(id: project_result.id)
              expect(before_project_result).to eq project_result
              expect(before_project_result.known_scope).to eq 10

              after_result_reload = ProjectResult.find_by(id: after_project_result.id)
              expect(after_result_reload).to eq after_project_result
              expect(after_result_reload.known_scope).to eq 11

              expect(ProjectResult.count).to eq 4

              expect(product.reload.team).to eq team
            end
          end

          context 'and the result has other demands' do
            let!(:first_demand) { Fabricate :demand, project: project, project_result: previous_project_result, created_date: 1.day.ago, end_date: Time.zone.today }
            let!(:second_demand) { Fabricate :demand, project: project, project_result: previous_project_result, created_date: 1.day.ago, end_date: nil }
            let!(:third_demand) { Fabricate :demand, project: project, project_result: previous_project_result, created_date: 1.day.ago, end_date: nil }

            context 'and the new result does not exist' do
              it 'moves the demand to the new project result' do
                team.team_members.first.destroy
                modified_team = team.reload

                ProjectResultService.instance.compute_demand!(modified_team, first_demand)

                new_project_result = first_demand.reload.project_result
                expect(new_project_result.id).not_to eq project_result.id
                expect(new_project_result.result_date).to eq Time.zone.today
                expect(new_project_result.demands).to eq [first_demand]
                expect(new_project_result.qty_hours_downstream).to eq first_demand.effort_downstream
                expect(new_project_result.qty_hours_upstream).to eq first_demand.effort_upstream
                expect(new_project_result.known_scope).to eq 13

                expect(ProjectResult.find_by(id: first_project_result.id)).to eq first_project_result

                expect(previous_project_result.reload.demands).to match_array [second_demand, third_demand]

                before_project_result = ProjectResult.find_by(id: project_result.id)
                expect(before_project_result.demands).to eq []
                expect(before_project_result.known_scope).to eq 10

                after_result_reload = ProjectResult.find_by(id: after_project_result.id)
                expect(after_result_reload).to eq after_project_result
                expect(after_result_reload.known_scope).to eq 13

                expect(ProjectResult.count).to eq 5

                expect(product.reload.team).to eq team
              end
            end
            context 'and the new result exists' do
              let(:project_result) { Fabricate :project_result, project: project, result_date: Time.zone.today }

              it 'moves the demand to the existent project_result' do
                ProjectResultService.instance.compute_demand!(team, first_demand)

                new_project_result = first_demand.reload.project_result
                expect(new_project_result.result_date).to eq Time.zone.today
                expect(new_project_result.demands).to eq [first_demand]

                updated_project_result = previous_project_result.reload.reload
                expect(updated_project_result.result_date).to eq 3.days.ago.to_date
                expect(updated_project_result.demands).to match_array [second_demand, third_demand]

                expect(ProjectResult.count).to eq 5

                expect(product.reload.team).to eq team
              end
            end
          end
        end
      end
      context 'dealing with invalid project result' do
        let!(:demand) { Fabricate :demand, project: project, project_result: nil, created_date: 4.weeks.from_now, end_date: nil }
        it 'does not process the project results' do
          ProjectResultService.instance.compute_demand!(team, demand)
          expect(ProjectResult.count).to eq 0
          expect(demand.reload.project_result).to eq nil
          expect(product.reload.team).to eq previous_team
        end
      end
    end
  end
end
