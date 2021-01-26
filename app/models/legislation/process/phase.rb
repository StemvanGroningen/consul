class Legislation::Process::Phase
  def initialize(start_date, end_date, enabled)
    @start_date = start_date
    @end_date = end_date
    @enabled = enabled
  end

  def enabled?
    @enabled
  end

  def started?
    @start_date.nil? || enabled? && Date.current >= @start_date
  end

  def open?
    @end_date.nil? || started? && Date.current <= @end_date
  end
end
