require 'google/api_client/client_secrets'
require 'google/apis/calendar_v3'

class GoogleCalendarService
  attr_accessor :service

  def initialize
    self.service = Google::Apis::CalendarV3::CalendarService.new
  end

  def authorize!(credentials)
    client_secrets = Google::APIClient::ClientSecrets.new(credentials)
    service.authorization = client_secrets.to_authorization
  end

  def calendars_list
    service.list_calendar_lists(max_results: 250).items
  end

  def events_list(calendar_id)
    service.list_events(calendar_id, max_results: 2500).items
  end
end
