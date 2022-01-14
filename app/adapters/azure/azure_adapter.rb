# frozen_string_literal: true

module Azure
  class AzureAdapter
    attr_reader :azure_account

    def initialize(azure_account)
      @azure_account = azure_account
    end

    private

    def client
      @client ||= AzureApiService.new(@azure_account)
    end
  end
end
