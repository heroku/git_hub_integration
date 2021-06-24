class Numeric
  MINUTE_SECONDS = 60
  HOUR_SECONDS = 60 * MINUTE_SECONDS
  DAY_SECONDS = 24 * HOUR_SECONDS

  def seconds
    self
  end
  alias :second :seconds

  def minutes
    self * MINUTE_SECONDS
  end
  alias :minute :minutes

  def hours
    self * HOUR_SECONDS
  end
  alias :hour :hours

  def days
    self * DAY_SECONDS
  end
  alias :day :days

  def from_now
    ::Time.now + self
  end
end
