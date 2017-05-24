#!/bin/bash

set -xe

confirmationNumber=$1
firstName=$2
lastName=$3

results_folder=/tmp/attempt
rm -rf $results_folder
mkdir -p $results_folder

# Loop will run for over an hour.
prevHash= #unitialized.
COUNTER=1
while [[  $COUNTER -lt 15000 ]]; do
	sleep .25

	# Message
	echo "Trying Southwest Checkin. Attempt: $COUNTER"
	echo "Confirmation Number: $1, First Name: $2, Last Name: $3"

	# Web requests
	#todo: this relies on html markup ids remaining unchanged.
	curl --data "confirmationNumber=${confirmationNumber}&firstName=${firstName}&lastName=${lastName}&submitButton=Check In" https://www.southwest.com/flight/retrieveCheckinDoc.html > $results_folder/${COUNTER}.html

	# Remove unique strings and get file hash.
	sed -i -e 's/(.*SW.*)//g' $results_folder/${COUNTER}.html
	curHash=`md5sum $results_folder/${COUNTER}.html | tr " " "\n" | head -1`

	# Is this page different than the previous result?
	# A different web response generally means success, but this is brittle. We could do much better
	if [[ -n $prevHash ]] && [[ $prevHash != $curHash ]]; then
		# Success!
		echo "Successfully checked in!"
		echo "See $results_folder for attempt results"
		break;
	fi

	echo # Newline
	prevHash=$curHash
	let COUNTER=COUNTER+1 
done

# todo: does this work for multiple passengers on the same itinerary?
# todo: does this automatically trigger the following "next" button?
