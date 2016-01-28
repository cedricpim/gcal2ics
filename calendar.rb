require 'yaml'
require_relative 'converters/converter'
require_relative 'converters/gcal_to_ics'
require_relative 'services/google_calendar_service'

DIR = ENV['DIR'] || File.join(Dir.pwd, 'calendars')

CREDENTIALS = YAML.load_file('credentials.yml')
SERVICE = GoogleCalendarService.new

Converter.new(GcalToIcs).run!
