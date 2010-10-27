module DateUtils
  def add_days(time, days)
    time + days * 86400
  end

  def add_hours(time,hours)
    time + hours * 3600
  end
end