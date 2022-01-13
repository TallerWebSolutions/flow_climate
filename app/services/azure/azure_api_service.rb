# frozen_string_literal: true

class AzureApiService
  include Singleton

  attr_reader :connection_parameters

  def initialize(username, api_token, base_uri)
    @connection_parameters = { username: username, password: api_token, base_uri: base_uri }
  end

  private

  def client
    HTTParty.get("#{@connection_parameters.base_uri}projects?api-version=2.0",
                 basic_auth: { username: @connection_parameters.username, password: @connection_parameters.password })
  end
end
