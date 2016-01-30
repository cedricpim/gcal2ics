class Converter
  attr_accessor :converter_klass

  def initialize(converter_klass)
    self.converter_klass = converter_klass
  end

  def run!
    CREDENTIALS.each do |credentials|
      SERVICE.authorize!(credentials)
      SERVICE.calendars_list.each do |api_calendar|
        method = ::SEPARATED ? :save_separated : :save_attached
        send(method, api_calendar, credentials['account'])
      end
    end
  end

  private

  def save_separated(api_calendar, account)
    SERVICE.events_list(api_calendar.id).each do |api_event|
      calendar = build_calendar(api_calendar)
      event = build_event(api_calendar, calendar, api_event)
      save(calendar, "#{event.uid}.ics", account)
    end
  end

  def save_attached(api_calendar, account)
    calendar = build_calendar(api_calendar)
    SERVICE.events_list(api_calendar.id).each do |api_event|
      build_event(api_calendar, calendar, api_event)
    end
    save(calendar, "#{calendar.x_wr_calname.first}.ics", account)
  end

  def build_calendar(*args)
    converter_klass.create_calendar(*args)
  end

  def build_event(*args)
    converter_klass.create_event(*args)
  end

  def save(*args)
    converter_klass.save(*args)
  end
end
