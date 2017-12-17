# NextTrain API

The **Next Train API** provides a JSON web service for any GTFS feed. Deploy this source code to your own Heroku server to set up an API for your own agency's feed. Let me know how it goes. I'm happy to support you!

Example request URL: `/api/v1/trains.json?date=2017-12-17&origin=BRN&destination=NHV`

Example response:

```js
{
  "query": {"origin": "BRN", "destination": "NHV", "date": "2017-12-17"},
  "received_at": "2017-12-17 18:00:14 -0500",
  "response_type": "Api::V1::TrainsResponse",
  "errors": [],
  "results": [
    {
      "schedule_id": 22,
      "service_guid": "WE",
      "route_guid": "SLE",
      "trip_headsign": "Westbound",
      "trip_guid": "3613",
      "origin_departure": "2017-12-17T07:24:00-0500",
      "destination_arrival": "2017-12-17T07:40:00-0500",
      "stops": [
        {
          "stop_sequence": 378,
          "stop_guid": "NLC",
          "arrival_time": "2017-12-17T06:30:00-0500",
          "departure_time": "2017-12-17T06:30:00-0500"
        },
        {
          "stop_sequence": 379,
          "stop_guid": "OSB",
          "arrival_time": "2017-12-17T06:55:00-0500",
          "departure_time": "2017-12-17T06:55:00-0500"
        },
        {
          "stop_sequence": 380,
          "stop_guid": "WES",
          "arrival_time": "2017-12-17T07:00:00-0500",
          "departure_time": "2017-12-17T07:00:00-0500"
        },
        {
          "stop_sequence": 381,
          "stop_guid": "CLIN",
          "arrival_time": "2017-12-17T07:05:00-0500",
          "departure_time": "2017-12-17T07:05:00-0500"
        },
        {
          "stop_sequence": 382,
          "stop_guid": "MAD",
          "arrival_time": "2017-12-17T07:10:00-0500",
          "departure_time": "2017-12-17T07:10:00-0500"
        },
        {
          "stop_sequence": 383,
          "stop_guid": "GUIL",
          "arrival_time": "2017-12-17T07:16:00-0500",
          "departure_time": "2017-12-17T07:16:00-0500"
        },
        {
          "stop_sequence": 384,
          "stop_guid": "BRN",
          "arrival_time": "2017-12-17T07:24:00-0500",
          "departure_time": "2017-12-17T07:24:00-0500"
        },
        {
          "stop_sequence": 385,
          "stop_guid": "ST",
          "arrival_time": "2017-12-17T07:37:00-0500",
          "departure_time": "2017-12-17T07:37:00-0500"
        },
        {
          "stop_sequence": 386,
          "stop_guid": "NHV",
          "arrival_time": "2017-12-17T07:40:00-0500",
          "departure_time": "2017-12-17T07:40:00-0500"
        }
      ]
    },
    // ... etc. ...
    {
      "schedule_id": 22,
      "service_guid": "WE",
      "route_guid": "SLE",
      "trip_headsign": "Westbound",
      "trip_guid": "3621",
      "origin_departure": "2017-12-17T09:19:00-0500",
      "destination_arrival": "2017-12-17T09:35:00-0500",
      "stops": [
        {
          "stop_sequence": 402,
          "stop_guid": "NLC",
          "arrival_time": "2017-12-17T08:25:00-0500",
          "departure_time": "2017-12-17T08:25:00-0500"
        },
        {
          "stop_sequence": 403,
          "stop_guid": "OSB",
          "arrival_time": "2017-12-17T08:50:00-0500",
          "departure_time": "2017-12-17T08:50:00-0500"
        },
        {
          "stop_sequence": 404,
          "stop_guid": "WES",
          "arrival_time": "2017-12-17T08:55:00-0500",
          "departure_time": "2017-12-17T08:55:00-0500"
        },
        {
          "stop_sequence": 405,
          "stop_guid": "CLIN",
          "arrival_time": "2017-12-17T09:00:00-0500",
          "departure_time": "2017-12-17T09:00:00-0500"
        },
        {
          "stop_sequence": 406,
          "stop_guid": "MAD",
          "arrival_time": "2017-12-17T09:05:00-0500",
          "departure_time": "2017-12-17T09:05:00-0500"
        },
        {
          "stop_sequence": 407,
          "stop_guid": "GUIL",
          "arrival_time": "2017-12-17T09:11:00-0500",
          "departure_time": "2017-12-17T09:11:00-0500"
        },
        {
          "stop_sequence": 408,
          "stop_guid": "BRN",
          "arrival_time": "2017-12-17T09:19:00-0500",
          "departure_time": "2017-12-17T09:19:00-0500"
        },
        {
          "stop_sequence": 409,
          "stop_guid": "ST",
          "arrival_time": "2017-12-17T09:32:00-0500",
          "departure_time": "2017-12-17T09:32:00-0500"
        },
        {
          "stop_sequence": 410,
          "stop_guid": "NHV",
          "arrival_time": "2017-12-17T09:35:00-0500",
          "departure_time": "2017-12-17T09:35:00-0500"
        }
      ]
    }
  ]
}
```

## [Contributing](/CONTRIBUTING.md)

## [Deploying](/DEPLOYING.md)

## [License](/LICENSE.md)
