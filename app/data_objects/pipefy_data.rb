# frozen_string_literal: true

class PipefyData
  attr_reader :demand_type, :commitment_date, :created_date, :end_date, :demand_id, :pipe_id, :url

  def initialize(card_response)
    @demand_id = card_response['data'].try(:[], 'card').try(:[], 'id')
    @pipe_id = card_response['data'].try(:[], 'card').try(:[], 'pipe').try(:[], 'id')
    @url = card_response['data'].try(:[], 'card').try(:[], 'url')
    define_demand_type(card_response['data'])
    read_phases(card_response['data'])
  end

  private

  def read_phases(response_data)
    response_data.try(:[], 'card').try(:[], 'phases_history')&.each do |phase|
      define_demand_dates(phase)
    end
  end

  def define_demand_dates(phase)
    if phase['phase']['name'] == 'Start form'
      @created_date = Time.iso8601(phase['firstTimeIn'])
    elsif phase['phase'].try(:[], 'fields')&.first.try(:[], 'label') == 'Commitment Point'
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
