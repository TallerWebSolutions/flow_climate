# frozen_string_literal: true

module PortfolioUnitHelper
  include ActionView::Helpers::NumberHelper

  def portfolio_unit_type_options(selected_value = :product_module)
    options_for_select(PortfolioUnit.portfolio_unit_types.keys.map { |unit| [I18n.t("activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.#{unit}"), unit] }, selected_value)
  end

  def build_portfolio_tree(children)
    html_output = ''

    if children.present?
      html_output += '<ul>'

      children.each do |child|
        html_output += '<li>'
        html_output += "<span class='tf-nc'>"
        html_output += "<div class='tf-header'>"
        html_output += "<div class='pull-left bottom-spaced-component'>#{number_to_currency(child.total_cost, precision: 2)}</div>"
        html_output += "<div class='pull-right bottom-spaced-component'>#{I18n.t('general.hours_text', count: number_with_precision(child.total_hours, precision: 2))}</div>"
        html_output += '</div>'
        html_output += "<div class='tf-nc-title'>#{link_to child.name, company_product_portfolio_unit_path(child.product.company, child.product, child), target: :_blank}</div>"
        html_output += "<div class='card-subtitle'>"
        html_output += I18n.t('general.demands_text', count: child.total_portfolio_demands.count)
        html_output += '</div>'
        html_output += "<div class='tf-footer'>"
        html_output += "<div class='col-xs-4'>#{number_to_percentage(child.percentage_complete * 100, precision: 2)}</div>"
        html_output += "<div class='col-xs-4'>LT #{number_with_precision(seconds_to_day(child.lead_time_p80), precision: 2)} #{I18n.t('general.days')}</div>"
        html_output += "<div class='col-xs-4 bottom-spaced-component'>#{I18n.t("activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.#{child.portfolio_unit_type}")}</div>"
        html_output += '</div>'
        html_output += '</span>'
        html_output += build_portfolio_tree(child.children) if child.children?
        html_output += '</li>'
      end

      html_output += + '</ul>'
    end

    html_output
  end
end
