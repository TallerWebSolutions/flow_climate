module PortfolioUnitHelper
  def portfolio_unit_type_options(selected_value = :product_module)
    options_for_select([[I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.product_module'), :product_module], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.key_result'), :key_result], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.impact'), :impact], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.source'), :source]], selected_value)
  end
end