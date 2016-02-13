class Converter
  attr_accessor :converter_klass

  def initialize(converter_klass)
    self.converter_klass = converter_klass
  end

  def run!
    CREDENTIALS.each do |credentials|
      SERVICE.authorize!(credentials)
      SERVICE.calendars_list.each do |api_calendar|
        status(api_calendar) if VERBOSE
        method = ::SEPARATED ? :save_separated : :save_attached
        send(method, api_calendar, credentials['account'])
      end
    end
    sync
  ensure
    FileUtils.remove_dir(TMP)
  end

  private

  def sync
    FileUtils.mkpath(DIR)
    directories.each do |directory|
      new_dir = File.join(DIR, directory.sub(/^#{TMP}/, ''))
      FileUtils.remove_dir(new_dir) if Dir.exist?(new_dir)
    end
    FileUtils.cp_r(directories, DIR)
  end

  def status(api_calendar)
    calendar_name = api_calendar.summary_override || api_calendar.summary
    puts "Downloading calendar: #{calendar_name}"
  end

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

  def save(ical, filename, account = nil)
    filepath = File.join([TMP, account, filename].compact)
    FileUtils.mkpath(File.dirname(filepath))
    File.open(filepath, 'w') { |f| f.write(ical.to_ical) }
  end

  def directories
    Dir[File.join(TMP, '**')]
  end

  def build_calendar(*args)
    converter_klass.create_calendar(*args)
  end

  def build_event(*args)
    converter_klass.create_event(*args)
  end
end
