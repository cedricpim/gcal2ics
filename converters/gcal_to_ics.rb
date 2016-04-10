require 'icalendar'

class GcalToIcs
  DATE_FORMAT = '%Y%m%d'

  class << self
    def create_calendar(calendar)
      Icalendar::Calendar.new.tap do |ical|
        ical.prodid        = calendar.id
        ical.x_wr_calname  = calendar.summary_override || calendar.summary
        ical.x_wr_caldesc  = calendar.description if calendar.description
        ical.timezone { |tz| tz.tzid = calendar.time_zone }
      end
    end

    def create_event(calendar, ical, event)
      return if event.status == 'cancelled'
      ical.event do |e|
        e.uid         = event.id
        e.dtstart     = parse_date(event.start || event.original_start_time, calendar.time_zone)
        e.dtend       = parse_date(event.end, calendar.time_zone)
        e.summary     = event.summary
        e.description = event.description
        e.ip_class    = event.visibility
        e.url         = event.html_link
        e.status      = event.status
        e.rrule       = event.recurrence
        e.attendee    = Array(event.attendees).map { |attendee| "mailto:#{attendee.email}" }
        create_alarms(e, event.reminders, calendar.default_reminders)
      end
    end

    private

    def parse_date(event_date, time_zone)
      return unless event_date
      time = event_date.date_time || event_date.date.try(:to_date)
      if time.is_a?(DateTime)
        Icalendar::Values::DateTime.new(time, tzid: time_zone)
      elsif time.is_a?(Date)
        Icalendar::Values::Date.new(time.strftime(DATE_FORMAT), tzid: time_zone)
      else
        fail UnknownDateFormatError, "Not recognizable date format: #{time.class}"
      end
    end

    def create_alarms(event, reminders, default_reminders)
      return unless reminders
      (reminders.use_default ? default_reminders : Array(reminders.overrides)).each do |reminder|
        event.alarm do |alarm|
          alarm.action  = reminder.reminder_method
          alarm.trigger = "-PT#{reminder.minutes}M"
        end
      end
    end
  end
end
