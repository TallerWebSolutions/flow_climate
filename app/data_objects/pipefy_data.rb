# frozen_string_literal: true

class PipefyData
  attr_reader :demand_type, :commitment_date, :created_date, :end_date, :demand_id, :pipe_id, :known_scope

  def initialize(card_response, pipe_response)
    @demand_id = card_response['data'].try(:[], 'card').try(:[], 'id')
    @pipe_id = card_response['data'].try(:[], 'card').try(:[], 'pipe').try(:[], 'id')
    @known_scope = pipe_known_scope(pipe_response)
    define_demand_type(card_response['data'])
    read_phases(card_response['data'])
  end

  private

  def pipe_known_scope(pipe_response)
    known_scope = 0
    pipe_response['data'].try(:[], 'pipe').try(:[], 'phases')&.each { |phase| known_scope += phase['cards']['edges'].count }
    known_scope
  end

  def read_phases(response_data)
    response_data.try(:[], 'card').try(:[], 'phases_history')&.each do |phase|
      define_demand_dates(phase)
    end
  end

  def define_demand_dates(phase)
    if phase['phase']['name'] == 'Start form'
      @created_date = Time.iso8601(phase['firstTimeIn'])
    elsif phase['phase'].try(:[], 'fields')&.first.try(:[], 'label') == 'Commitment Point?'
      @commitment_date = Time.iso8601(phase['firstTimeIn'])
    elsif phase['phase']['done']
      @end_date = Time.iso8601(phase['firstTimeIn'])
    end
  end

  def define_demand_type(response_data)
    @demand_type = :feature

    response_data.try(:[], 'card').try(:[], 'fields')&.each do |field|
      next unless field['name'].casecmp('type').zero?
      @demand_type = if field['value'].casecmp('bug').zero?
                       :bug
                     elsif field['value'].casecmp('nova funcionalidade').zero?
                       :feature
                     else
                       :chore
                     end
    end
  end
end
