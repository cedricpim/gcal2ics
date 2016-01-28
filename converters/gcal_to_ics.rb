require 'icalendar'

class GcalToIcs
  def self.create_calendar(calendar)
    Icalendar::Calendar.new.tap do |ical|
      ical.prodid        = calendar.id
      ical.x_wr_calname  = calendar.summary_override || calendar.summary
      ical.x_wr_caldesc  = calendar.description if calendar.description
      ical.timezone { |tz| tz.tzid = calendar.time_zone }
    end
  end

  def self.create_event(ical, event)
    return if event.status == 'cancelled'
    ical.event do |e|
      e.dtstart     = event.start.date_time || event.start.date.to_date
      e.dtend       = event.end.date_time || event.end.date.to_date
      e.summary     = event.summary
      e.description = event.description
      e.ip_class    = event.visibility
      e.url         = event.html_link
      e.status      = event.status
    end
  end

  def self.save(ical, account = nil)
    filepath = File.join([DIR, account, "#{ical.x_wr_calname.first}.ics"].compact)
    FileUtils.mkpath(File.dirname(filepath))
    File.open(filepath, 'w') { |f| f.write(ical.to_ical) }
  end
end
