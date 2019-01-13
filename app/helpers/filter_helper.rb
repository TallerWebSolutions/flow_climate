module FilterHelper
  def period_options(selected_value = :month)
    options_for_select([[I18n.t('general.filter.period.option.last_month'), 'month'], [I18n.t('general.filter.period.option.last_quarter'), 'quarter'], [I18n.t('general.filter.period.option.all_period'), 'all']], selected_value)
  end
end
