# How to extract the data

## Sessions

* Open Chrome and the dev tools (F12)

* Browse to https://app.socio.events/MjQ4Nw/Overview/14440

* Look for a response called `sessions` with method `GET`.  Should be > 100KB payload

* Extract the JSON response

* Use something like https://jsonlint.com/ to reformat the response into readable JSON

* Update `sessions.json` (Convert indentation to Spaces)

## Speakers

* Open Chrome and the dev tools (F12)

* Browse to https://app.socio.events/MjQ4Nw/Overview/14440

* Look for a response called `items` with method `GET`.  Should be > 40KB payload (https://attendee.socio.events/events/2487/components/14446/items)

* Extract the JSON response

* Use something like https://jsonlint.com/ to reformat the response into readable JSON

* Update `speakers.json` (Convert indentation to Spaces)
