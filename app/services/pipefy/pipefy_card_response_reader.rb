# frozen_string_literal: true

module Pipefy
  class PipefyCardResponseReader
    include Singleton

    def create_card!(project, team, card_response)
      response_data = card_response['data']

      create_assignees!(team, response_data)

      demand = create_demand!(team, project, response_data)
      read_phases_transitions(demand.reload, response_data) if demand.present?

      demand
    end

    def update_card!(project, team, demand, card_response)
      return if card_response.blank? || card_response['data'].blank?

      if card_response['data']['card'].blank?
        DemandsRepository.instance.full_demand_destroy!(demand)
        return
      end

      process_update!(project, demand, card_response['data'], team)
    end

    private

    def process_update!(project, demand, response_data, team)
      demand.update(project: project)

      create_assignees!(team, response_data)

      read_phases_transitions(demand.reload, response_data)
      read_blocks(demand.reload, response_data)
      update_demand!(team, demand, response_data)
      process_demand(demand.reload, team)
    end

    def process_demand(demand, team)
      demand.update_created_date! if demand.demand_transitions.present?
      project_result = ProjectResultService.instance.compute_demand!(team, demand)
      IntegrationError.build_integration_error(demand, project_result, :pipefy) unless project_result.valid?
    end

    def create_assignees!(team, response_data)
      return if empty_assignees?(response_data)
      response_data['card']['assignees'].uniq.each { |assignee| Pipefy::PipefyTeamConfig.where(team: team, integration_id: assignee['id'], username: assignee['username']).first_or_create }
    end

    # TODO: move to DemandsRepository
    def create_demand!(team, project, response_data)
      demand_id = response_data.try(:[], 'card').try(:[], 'id')
      return if demand_id.blank?
      assignees_count = compute_assignees_count(team, response_data)
      url = response_data.try(:[], 'card').try(:[], 'url')

      demand = Demand.find_by(demand_id: demand_id, project: project)
      return demand if demand.present?

      Demand.create(project: project, demand_id: demand_id, created_date: Time.zone.now, demand_type: read_demand_type(response_data), class_of_service: read_class_of_service(response_data), assignees_count: assignees_count, url: url)
    end

    def update_demand!(team, demand, response_data)
      demand_id = response_data.try(:[], 'card').try(:[], 'id')
      assignees_count = compute_assignees_count(team, response_data)
      url = response_data.try(:[], 'card').try(:[], 'url')

      demand.update!(demand_id: demand_id, demand_type: read_demand_type(response_data), class_of_service: read_class_of_service(response_data), assignees_count: assignees_count, url: url)
      demand.project_result&.compute_flow_metrics!
    end

    def compute_assignees_count(team, response_data)
      return 1 if empty_assignees?(response_data)

      assigned_usernames = response_data['card']['assignees'].uniq.map { |assignee| assignee['username'] }
      developers = Pipefy::PipefyTeamConfig.where(team: team, username: assigned_usernames, member_type: :developer)
      developers.count
    end

    def empty_assignees?(response_data)
      response_data.blank? || response_data['card'].blank? || response_data['card']['assignees'].blank?
    end

    def read_phases_transitions(demand, response_data)
      transitions = []
      response_data.try(:[], 'card').try(:[], 'phases_history')&.each do |phase|
        transition_data = {}
        transition_data[:phase_id] = phase['phase']['id']
        transition_data[:first_time_in] = Time.iso8601(phase['firstTimeIn'])
        transition_data[:last_time_out] = Time.iso8601(phase['lastTimeOut']) if phase['lastTimeOut'].present?

        transitions << transition_data
      end
      create_transition_for_phase_and_demand(demand, transitions.sort_by { |hash| hash[:first_time_in] })
    end

    def create_transition_for_phase_and_demand(demand, transitions)
      last_transition_out = nil
      transitions.each do |transition_hash|
        last_transition_out = transition_hash[:first_time_in] if last_transition_out.blank?
        stage = Stage.find_by(integration_id: transition_hash[:phase_id])
        next if stage.blank? || demand.blank?
        DemandTransition.where(stage: stage, demand: demand).map(&:destroy)
        demand_transition = DemandTransition.create(stage: stage, demand: demand, last_time_in: last_transition_out, last_time_out: transition_hash[:last_time_out])
        last_transition_out = transition_hash[:last_time_out]
        IntegrationError.build_integration_error(demand, demand_transition, :pipefy) unless demand_transition.valid?
      end
    end

    def read_demand_type(response_data)
      demand_type_in_response = :feature
      response_data.try(:[], 'card').try(:[], 'fields')&.each do |field|
        next unless field['name'].casecmp('type').zero?
        demand_type_in_response = define_demand_type(field['value'])
        break
      end
      demand_type_in_response
    end

    def define_demand_type(demand_type)
      if demand_type.casecmp('bug').zero?
        :bug
      elsif demand_type.casecmp('melhoria performance').zero?
        :performance_improvement
      elsif demand_type.casecmp('melhoria ux').zero?
        :ux_improvement
      elsif demand_type.casecmp('chore').zero?
        :chore
      else
        :feature
      end
    end

    def read_class_of_service(response_data)
      demand_class_of_service = :standard
      response_data.try(:[], 'card').try(:[], 'fields')&.each do |field|
        next unless field['name'].casecmp('class of service').zero?
        demand_class_of_service = if field['value'].casecmp('expedição').zero?
                                    :expedite
                                  elsif field['value'].casecmp('data fixa').zero?
                                    :fixed_date
                                  elsif field['value'].casecmp('intangível').zero?
                                    :intangible
                                  else
                                    :standard
                                  end
      end
      demand_class_of_service
    end

    def read_blocks(demand, response_data)
      response_data.try(:[], 'card').try(:[], 'comments')&.each do |comment_pipefy|
        comment_text = comment_pipefy['text']
        demand_block_id = '1'
        demand_block_id = comment_text.scan(/\[[0-9a-f]\]/).first.delete('[').delete(']').strip if /\[[0-9a-f]\]/.match?(comment_text)

        if comment_text.start_with?('[BLOCKED]')
          persist_block(demand, comment_pipefy, demand_block_id, comment_text)
        elsif comment_text.start_with?('[UNBLOCKED]')
          persist_unblock(demand, comment_pipefy, demand_block_id, comment_text)
        end
      end
    end

    def persist_block(demand, comment_pipefy, demand_block_id, comment_text)
      demand_block = demand.demand_blocks.where(demand_block_id: demand_block_id, block_time: Time.zone.iso8601(comment_pipefy['created_at'])).first_or_initialize
      demand_block.update(demand: demand, demand_block_id: demand_block_id, blocker_username: comment_pipefy['author']['username'], block_time: comment_pipefy['created_at'], block_reason: comment_text.strip)
    end

    def persist_unblock(demand, comment_pipefy, demand_block_id, comment_text)
      demand_block = demand.demand_blocks.open.where(demand: demand, demand_block_id: demand_block_id).first
      return if demand_block.blank?
      demand_block.update(unblocker_username: comment_pipefy['author']['username'], unblock_time: comment_pipefy['created_at'], unblock_reason: comment_text.strip)
    end
  end
end
