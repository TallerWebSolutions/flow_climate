module DateHelper
  def time_distance_in_words(time_in_seconds)
    seconds_in_a_day = 24 * 60 * 60
    seconds_in_a_hour = 60 * 60
    seconds_in_a_minute = 60

    days = (time_in_seconds.to_f / seconds_in_a_day.to_f).to_i

    hours = ((time_in_seconds - days * seconds_in_a_day.to_f) / seconds_in_a_hour).to_i

    minutes = ((time_in_seconds - hours * seconds_in_a_hour.to_f) / seconds_in_a_minute).to_i

    return "#{time_in_seconds.to_i} #{I18n.t('datetime.date_attributes.second', count: time_in_seconds)}" if days < 1 && hours < 1 && minutes < 1
    return "#{minutes} #{I18n.t('datetime.date_attributes.minute', count: minutes)}" if days < 1 && hours < 1
    return "#{hours} #{I18n.t('datetime.date_attributes.hour', count: hours)}" if days < 1
    return "#{days} #{I18n.t('datetime.date_attributes.day', count: days)} #{I18n.t('geenral.connector.and')} #{hours} #{I18n.t('datetime.date_attributes.hour', count: hours)}" if hours.positive?
    "#{days} #{I18n.t('datetime.date_attributes.day', count: days)}"
  end

  def seconds_to_day(date_in_seconds)
    date_in_seconds.to_f / 1.day
  end
end