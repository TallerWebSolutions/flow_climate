# frozen_string_literal: true

module Jira
  class JiraCustomFieldMappingsController < AuthenticatedController
    before_action :user_gold_check

    before_action :assign_jira_account
    before_action :assign_jira_custom_field_mapping, only: %i[edit update destroy]

    def new
      @jira_custom_field_mapping = Jira::JiraCustomFieldMapping.new(jira_account: @jira_account)

      assign_jira_custom_field_mappings_list

      respond_to { |format| format.js { render 'jira/jira_custom_field_mappings/new' } }
    end

    def create
      @jira_custom_field_mapping = Jira::JiraCustomFieldMapping.create(jira_custom_field_mapping_params.merge(jira_account: @jira_account))

      assign_jira_custom_field_mappings_list

      respond_to { |format| format.js { render 'jira/jira_custom_field_mappings/create' } }
    end

    def edit
      assign_jira_custom_field_mappings_list

      respond_to { |format| format.js { render 'jira/jira_custom_field_mappings/edit' } }
    end

    def update
      @jira_custom_field_mapping.update(jira_custom_field_mapping_params)

      assign_jira_custom_field_mappings_list

      respond_to { |format| format.js { render 'jira/jira_custom_field_mappings/update' } }
    end

    def destroy
      @jira_custom_field_mapping.destroy
      assign_jira_custom_field_mappings_list

      respond_to { |format| format.js { render 'jira/jira_custom_field_mappings/destroy' } }
    end

    private

    def assign_jira_account
      @jira_account = @company.jira_accounts.find(params[:jira_account_id])
    end

    def assign_jira_custom_field_mappings_list
      @jira_custom_field_mappings = @jira_account.jira_custom_field_mappings
    end

    def assign_jira_custom_field_mapping
      @jira_custom_field_mapping = Jira::JiraCustomFieldMapping.find(params[:id])
    end

    def jira_custom_field_mapping_params
      params.require(:jira_jira_custom_field_mapping).permit(:custom_field_machine_name, :custom_field_type)
    end
  end
end
