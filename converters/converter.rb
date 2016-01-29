class Converter
  attr_accessor :converter_klass

  def initialize(converter_klass)
    self.converter_klass = converter_klass
  end

  def run!
    CREDENTIALS.each do |credentials|
      SERVICE.authorize!(credentials)
      SERVICE.calendars_list.each do |api_calendar|
        calendar = calendar(api_calendar)
        SERVICE.events_list(calendar.prodid).each do |api_event|
          event(api_calendar, calendar, api_event)
        end
        save(calendar, credentials['account'])
      end
    end
  end

  private

  def calendar(*args)
    converter_klass.create_calendar(*args)
  end

  def event(*args)
    converter_klass.create_event(*args)
  end

  def save(*args)
    converter_klass.save(*args)
  end
end
