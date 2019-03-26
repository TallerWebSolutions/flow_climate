# frozen_string_literal: true

RSpec.describe DemandBlocksRepository, type: :repository do
  describe '#closed_blocks_to_projects_and_period_grouped' do
    let!(:first_project) { Fabricate :project, status: :maintenance, start_date: 3.days.ago, end_date: 2.days.ago }
    let!(:second_project) { Fabricate :project, status: :executing, start_date: 3.days.ago, end_date: Time.zone.today }

    context 'having data' do
      let!(:first_demand) { Fabricate :demand, project: first_project }
      let!(:second_demand) { Fabricate :demand, project: first_project }
      let!(:third_demand) { Fabricate :demand, project: second_project }
      let!(:fourth_demand) { Fabricate :demand, project: first_project }

      let!(:fifth_demand) { Fabricate :demand, project: first_project }

      let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true }
      let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: 2.days.ago }
      let!(:third_block) { Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: 4.days.ago }
      let!(:fourth_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: Time.zone.yesterday }
      let!(:fifth_block) { Fabricate :demand_block, demand: third_demand, block_time: 5.days.ago, unblock_time: 3.days.ago }
      let!(:sixth_block) { Fabricate :demand_block, demand: fourth_demand, block_time: 2.days.ago, unblock_time: Time.zone.today }

      it 'returns the grouped data' do
        blocks_grouped_data = DemandBlocksRepository.instance.closed_blocks_to_projects_and_period_grouped([first_project, second_project], first_project.start_date, second_project.end_date)
        expect(blocks_grouped_data.keys).to eq([first_project.full_name])
        expect(blocks_grouped_data.values[0].first).to eq third_block
      end
    end

    context 'having no data' do
      it { expect(DemandBlocksRepository.instance.closed_blocks_to_projects_and_period_grouped([first_project, second_project], first_project.start_date, second_project.end_date)).to eq({}) }
    end
  end

  describe '#active_blocks_to_projects_and_period' do
    let!(:first_project) { Fabricate :project, status: :maintenance, start_date: 3.days.ago, end_date: 2.days.ago }
    let!(:second_project) { Fabricate :project, status: :executing, start_date: 3.days.ago, end_date: Time.zone.today }
    let!(:third_project) { Fabricate :project, status: :executing, start_date: 3.days.ago, end_date: Time.zone.today }

    context 'having data' do
      let!(:first_demand) { Fabricate :demand, project: first_project }
      let!(:second_demand) { Fabricate :demand, project: first_project }
      let!(:third_demand) { Fabricate :demand, project: second_project }
      let!(:fourth_demand) { Fabricate :demand, project: first_project }

      let!(:fifth_demand) { Fabricate :demand, project: third_project }

      let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true }
      let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: 2.days.ago, active: true }
      let!(:third_block) { Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: 4.days.ago, active: true }
      let!(:fourth_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: Time.zone.yesterday, active: true }
      let!(:fifth_block) { Fabricate :demand_block, demand: third_demand, block_time: 5.days.ago, unblock_time: 3.days.ago, active: true }
      let!(:sixth_block) { Fabricate :demand_block, demand: fourth_demand, block_time: 2.days.ago, unblock_time: Time.zone.today, active: true }

      let!(:seventh_block) { Fabricate :demand_block, demand: fifth_demand, block_time: 2.days.ago, unblock_time: Time.zone.today, active: true }

      it 'returns the grouped data' do
        blocks_grouped_data = DemandBlocksRepository.instance.active_blocks_to_projects_and_period([first_project, second_project], first_project.start_date, second_project.end_date)
        expect(blocks_grouped_data).to match_array [first_block, second_block, third_block, fourth_block, sixth_block]
      end
    end

    context 'having no data' do
      it { expect(DemandBlocksRepository.instance.active_blocks_to_projects_and_period([first_project, second_project], first_project.start_date, second_project.end_date)).to eq [] }
    end
  end

  describe '#accumulated_blocks_to_date' do
    let!(:first_project) { Fabricate :project, status: :maintenance, start_date: 3.days.ago, end_date: 2.days.ago }
    let!(:second_project) { Fabricate :project, status: :executing, start_date: 3.days.ago, end_date: Time.zone.today }

    context 'having data' do
      let!(:first_demand) { Fabricate :demand, project: first_project }
      let!(:second_demand) { Fabricate :demand, project: first_project }
      let!(:third_demand) { Fabricate :demand, project: second_project }
      let!(:fourth_demand) { Fabricate :demand, project: first_project }

      let!(:fifth_demand) { Fabricate :demand, project: first_project }

      let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true }
      let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: 2.days.ago }
      let!(:third_block) { Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: 4.days.ago }
      let!(:fourth_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: Time.zone.yesterday }
      let!(:fifth_block) { Fabricate :demand_block, demand: third_demand, block_time: 5.days.ago, unblock_time: 3.days.ago }
      let!(:sixth_block) { Fabricate :demand_block, demand: fourth_demand, block_time: 2.days.ago, unblock_time: Time.zone.today }

      it 'returns the grouped data' do
        blocks_grouped_data = DemandBlocksRepository.instance.accumulated_blocks_to_date([first_project, second_project], second_project.end_date)
        expect(blocks_grouped_data).to eq 4
      end
    end

    context 'having no data' do
      it { expect(DemandBlocksRepository.instance.accumulated_blocks_to_date([first_project, second_project], second_project.end_date)).to eq 0 }
    end
  end
end
