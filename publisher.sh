# Create a Payload for test
#!/bin/bash
source .env

HOST=$1
THING=$2
SENSOR=$3

PSQL="psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB"

if [ -n "$HOST" ]; then
    MOSQUITTO_HOST=$HOST
fi

PUB="mosquitto_pub -i "scriptPublisher" -h $MOSQUITTO_HOST -u $MOSQUITTO_USER -P $MOSQUITTO_PASSWORD -q $MOSQUITTO_QOS"

if [ -z "$THING" ]; then
    THING=$($PSQL -c "select id from things limit 1" -t)
fi

UUID=$($PSQL -c "select uuid from things where id = $THING" -t)

if [ -z "$SENSOR" ]; then
    THINGSENSOR=$($PSQL -c "select id_sensor from thingssensors where id_thing = $THING limit 1" -t)
else
    THINGSENSOR=$($PSQL -c "select id_sensor from thingssensors where id_thing = $THING and id_sensor = $SENSOR" -t)
fi

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

echo -e "Host:\t$MOSQUITTO_HOST"
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

