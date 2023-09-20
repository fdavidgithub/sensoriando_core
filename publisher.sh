# Create a Payload for test
#!/bin/bash
source .env

THING=$1

PSQL="psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB"
PUB="mosquitto_pub -i "scriptPublisher" -h $MOSQUITTO_HOST -u $MOSQUITTO_USER -P $MOSQUITTO_PASSWORD -q $MOSQUITTO_QOS"

if [ -z "$THING" ]; then
    export THING=1
fi

UUID=$($PSQL -c "select uuid from things where id = $THING" -t)
THINGSENSOR=$($PSQL -c "select id from thingssensors where id_thing = $THING limit 1" -t)

if [ -z "$UUID" ]; then
    echo -e "Thing ID $THING do not found"
    exit 1
fi

if [ -z "$THINGSENSOR"  ]; then
    echo -e "Sensor do not found"
    exit 1
fi

VALUE=$(((RANDOM % 100) +1))
DATE=$(date -u '+%Y%m%d%H%M%S')
PAYLOAD="{\"dt\": \"$DATE\", \"value\": $VALUE}"

TOPIC=$UUID/$THINGSENSOR
TOPIC=$(echo $TOPIC | sed 's/ //g') #Remove whitespace

echo -e "Thing:\t$UUID"
echo -e "Sensor:\t$THINGSENSOR"
echo -e "Topic:\t$TOPIC"
echo -e "Payload:\t$PAYLOAD"
echo -e "\n"

if [ $MOSQUITTO_RETAINED -eq 1 ]; then
	$PUB -r -t $TOPIC -m "$PAYLOAD"
else
	$PUB -t $TOPIC -m "$PAYLOAD"
fi

exit 0

