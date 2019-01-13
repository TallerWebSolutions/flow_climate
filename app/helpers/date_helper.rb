module DateHelper
  def time_distance_in_words(time_in_seconds)
    seconds_in_a_day = 24 * 60 * 60
    seconds_in_a_hour = 60 * 60

    days = (time_in_seconds.to_f / seconds_in_a_day.to_f).to_i

    hours = ((time_in_seconds - days * seconds_in_a_day) / seconds_in_a_hour).to_i

    return "#{hours} #{I18n.t('datetime.date_attributes.hour', count: hours)}" if days < 1
    return "#{days} #{I18n.t('datetime.date_attributes.day', count: days)} #{I18n.t('geenral.connector.and')} #{hours} #{I18n.t('datetime.date_attributes.hour', count: hours)}" if hours.positive?
    "#{days} #{I18n.t('datetime.date_attributes.day', count: days)}"
  end
end