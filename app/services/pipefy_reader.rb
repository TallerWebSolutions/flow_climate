# frozen_string_literal: true

class PipefyReader
  include Singleton

  def process_card(team, card_response)
    response_data = card_response['data']
    name_in_pipefy = read_project_name_from_pipefy_data(response_data)
    return if name_in_pipefy.blank?

    project = ProjectsRepository.instance.search_project_by_full_name(name_in_pipefy)
    return unless project&.pipefy_config&.active?

    create_assignees!(team, response_data)

    demand = create_demand(team, project, response_data)

    read_phases_transitions(demand.reload, response_data)
    read_blocks(demand.reload, response_data)
    process_demand(demand.reload, team)
    project
  end

  private

  def process_demand(demand, team)
    demand.update_effort!
    demand.update_created_date!
    project_result = ProjectResultsRepository.instance.create_project_result!(demand, team)
    return IntegrationError.create(company: team.company, integration_type: :pipefy, integration_error_text: project_result.errors.full_messages.join(', ')) unless project_result.valid?
    ProjectResult.reset_counters(project_result.id, :demands_count)
  end

  def create_assignees!(team, response_data)
    return if empty_assignees?(response_data)
    response_data['card']['assignees'].uniq.each { |assignee| PipefyTeamConfig.where(team: team, integration_id: assignee['id'], username: assignee['username']).first_or_create }
  end

  def read_project_name_from_pipefy_data(response_data)
    project_pipefy_name = ''
    response_data.try(:[], 'card').try(:[], 'fields')&.each do |field|
      next unless field['name'].casecmp('project').zero?
      project_pipefy_name = field['value']
    end
    project_pipefy_name
  end

  # TODO: move to DemandsRepository
  def create_demand(team, project, response_data)
    demand_id = response_data.try(:[], 'card').try(:[], 'id')
    assignees_count = compute_assignees_count(team, response_data)
    url = response_data.try(:[], 'card').try(:[], 'url')

    destroy_demand_if_exists!(demand_id, project)
    Demand.create(project: project, demand_id: demand_id, created_date: Time.zone.now, demand_type: read_demand_type(response_data), class_of_service: read_class_of_service(response_data), assignees_count: assignees_count, url: url)
  end

  def destroy_demand_if_exists!(demand_id, project)
    demand = Demand.where(project: project, demand_id: demand_id).first
    return if demand.blank?
    previous_result = demand.project_result
    previous_result.remove_demand!(demand) if previous_result.present?
    demand.destroy
  end

  def compute_assignees_count(team, response_data)
    return 1 if empty_assignees?(response_data)

    assigned_usernames = response_data['card']['assignees'].uniq.map { |assignee| assignee['username'] }
    developers = PipefyTeamConfig.where(team: team, username: assigned_usernames, member_type: :developer)
    developers.count
  end

  def empty_assignees?(response_data)
    response_data.blank? || response_data['card'].blank? || response_data['card']['assignees'].blank?
  end

  def read_phases_transitions(demand, response_data)
    demand.demand_transitions.destroy_all
    response_data.try(:[], 'card').try(:[], 'phases_history')&.each do |phase|
      create_transition_for_phase_and_demand(phase, demand)
    end
  end

  def create_transition_for_phase_and_demand(phase, demand)
    phase_id = phase['phase']['id']
    stage = Stage.where(integration_id: phase_id).first
    return if stage.blank? || demand.blank?
    last_time_out = nil
    last_time_out = Time.iso8601(phase['lastTimeOut']) if phase['lastTimeOut'].present?
    DemandTransition.where(stage: stage, demand: demand, last_time_in: phase['firstTimeIn'], last_time_out: last_time_out).first_or_create
  end

  def read_demand_type(response_data)
    demand_type_in_response = :feature
    response_data.try(:[], 'card').try(:[], 'fields')&.each do |field|
      next unless field['name'].casecmp('type').zero?
      demand_type_in_response = if field['value'].casecmp('bug').zero?
                                  :bug
                                elsif field['value'].casecmp('nova funcionalidade').zero?
                                  :feature
                                else
                                  :chore
                                end
    end
    demand_type_in_response
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

      persist_block(demand, comment_pipefy, demand_block_id, comment_text)
    end
  end

  def persist_block(demand, comment_pipefy, demand_block_id, comment_text)
    if comment_text.start_with?('[BLOCKED]')
      DemandBlock.create(demand: demand, demand_block_id: demand_block_id, blocker_username: comment_pipefy['author']['username'], block_time: comment_pipefy['created_at'], block_reason: comment_text.strip)
    elsif comment_text.start_with?('[UNBLOCKED]')
      demand_block = DemandBlock.where(demand: demand, demand_block_id: demand_block_id).first
      demand_block.update(unblocker_username: comment_pipefy['author']['username'], unblock_time: comment_pipefy['created_at'], unblock_reason: comment_text.strip)
    end
  end
end
