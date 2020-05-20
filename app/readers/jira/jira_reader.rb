# frozen_string_literal: true

module Jira
  class JiraReader
    include Singleton

    def read_project(jira_issue_attrs, jira_account)
      projects_names = read_project_name(jira_issue_attrs)

      jira_product_key = read_product_jira_key(jira_issue_attrs)
      jira_product = jira_account.company.jira_product_configs.where(jira_product_key: jira_product_key).first
      return if jira_product.blank?

      jira_config = nil
      projects_names.each do |project_name|
        jira_config = jira_product.jira_project_configs.find_by(fix_version_name: project_name)
        break if jira_config.present?
      end

      return if jira_config.blank?

      jira_config.project
    end

    def read_product(jira_issue_attrs, jira_account)
      jira_product_key = read_product_jira_key(jira_issue_attrs)
      jira_product = jira_account.company.jira_product_configs.where(jira_product_key: jira_product_key).first
      return if jira_product.blank?

      jira_product.product
    end

    def read_customer(jira_account, jira_issue_attrs)
      customer_custom_field_name = jira_account.customer_custom_field&.custom_field_machine_name

      jira_custom_fields_hash = build_jira_custom_fields_hash(jira_issue_attrs)

      customer_name = jira_custom_fields_hash[customer_custom_field_name]

      jira_account.company.customers.find_by(name: customer_name[0]['value']) if customer_name.present? && customer_name[0].present?
    end

    def read_demand_key(jira_issue_attrs)
      jira_issue_attrs['key']
    end

    def read_project_url(jira_issue_attrs)
      jira_issue_attrs['fields']['project']['self']
    end

    def read_class_of_service(jira_account, jira_issue_attrs, jira_issue_changelog)
      class_of_service_name = read_class_of_service_by_tag_name(jira_issue_changelog)

      class_of_service_name = read_class_of_service_custom_field_id(jira_account, jira_issue_attrs) if class_of_service_name.blank?

      if class_of_service_name.casecmp('expedite').zero?
        :expedite
      elsif class_of_service_name.casecmp('fixed date').zero?
        :fixed_date
      elsif class_of_service_name.casecmp('intangible').zero?
        :intangible
      else
        :standard
      end
    end

    def read_portfolio_unit(jira_issue_changelog, jira_issue_attrs, product)
      jira_history_fields_hash = build_history_fields_hash(jira_issue_changelog)
      jira_custom_fields_hash = jira_history_fields_hash.merge(build_jira_custom_fields_hash(jira_issue_attrs))

      portfolio_units = product.portfolio_units

      portfolio_unit = nil
      portfolio_units.each do |unit|
        portfolio_unit_value = jira_custom_fields_hash[unit.jira_portfolio_unit_config.jira_field_name]
        next if portfolio_unit_value.blank?

        portfolio_unit = portfolio_units.find_by(name: portfolio_unit_value)
        break
      end

      portfolio_unit
    end

    private

    def build_history_fields_hash(jira_issue)
      jira_history_fields_hash = {}

      jira_issue['histories'].sort_by { |history| history['created'] }.each do |history|
        next if history['items'].blank?

        history['items'].each do |item|
          jira_history_fields_hash[item['field']] = item['toString']
        end
      end

      jira_history_fields_hash
    end

    def read_project_name(jira_issue_attrs)
      labels = jira_issue_attrs['fields']['labels'] || []
      fix_version_name = read_fix_version_name(jira_issue_attrs)

      labels << fix_version_name
      labels.reject(&:empty?)
    end

    def read_fix_version_name(jira_issue_attrs)
      return '' if jira_issue_attrs['fields']['fixVersions'].blank?

      jira_issue_attrs['fields']['fixVersions'][0]['name']
    end

    def read_product_jira_key(jira_issue_attrs)
      jira_issue_attrs['fields']['project']['key']
    end

    def read_class_of_service_custom_field_id(jira_account, jira_issue_attrs)
      class_of_service_custom_field_name = jira_account.class_of_service_custom_field&.custom_field_machine_name

      jira_custom_fields_hash = build_jira_custom_fields_hash(jira_issue_attrs)

      if class_of_service_custom_field_name.blank?
        class_of_service_name = 'standard'
      else
        class_of_service_hash = jira_custom_fields_hash[class_of_service_custom_field_name]

        class_of_service_name = if class_of_service_hash.blank?
                                  'standard'
                                else
                                  class_of_service_hash['value']
                                end
      end
      class_of_service_name
    end

    def read_class_of_service_by_tag_name(jira_issue_changelog)
      class_of_service = ''
      return class_of_service if jira_issue_changelog.blank?

      jira_issue_changelog['histories'].sort_by { |history_hash| history_hash['created'] }.each do |history|
        next unless history['items'].present? && class_of_service_field?(history)

        class_of_service = history['items'].first['toString']
      end
      class_of_service
    end

    def class_of_service_field?(history)
      (history['items'].first['field'].downcase.include?('class of service') || history['items'].first['field'].downcase.include?('classe de serviço'))
    end

    def build_jira_custom_fields_hash(jira_issue_attrs)
      jira_issue_attrs['fields'].select { |field| field.start_with?('customfield') }
    end
  end
end
