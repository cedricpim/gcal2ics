# gcal2ics

Coming from the idea of using [khal](https://github.com/geier/khal) and since [vdirsyncer](https://github.com/untitaker/vdirsyncer) currently does not support Google authentication, this project will connect with Google Calendar Api and convert any of the calendars to format `.ics`, allowing these files to be kept locally and imported to different calendar clients.

The project was developed with other possible converstions in mind, allowing for easy extension. No tests have been created because of the fact that it retrieves calendars using `google-api-client` and converts them using `icalendar`.

## Installation

Run `bundle` to install its dependencies.
Copy `credentials.example.yml` to `credentials.yml` and replace the present values for your own credentials.

## Usage

Command: `ruby calendar.rb`

Environment variable `DIR` can be defined as well to declare on which folder the calendars should be saved to like: `DIR=~/calendars ruby calendar.rb`. This will stored all downloaded calendars to `~/calendars`.

Lastly, and this came with the need to make it work with Khal, it is possible to define the option `--separated-events` so that each event is stored on a different file. This can be used like: `ruby calendar.rb --separated-events`.
