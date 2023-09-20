#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <MQTTClient.h>
#include <unistd.h>

#include "database.h"

#define MQTT_TOPIC  "#" /* Topic wildcard */
#define MQTT_ID     "Broker"
#define MQTT_QOS    2   /* Once and one only - the message will be delivered exactly once. */

#define LEN_UUID    36


/*
 * Constants
 */
const char help_param[]     = "-h";
const char config_param[]   = "-c";
const char verbose_param[]  = "-v";


/*
 *  Global variables
 */
int verbose = 0;
 
PGconn *conn;           /* Server Postgres */
MQTTClient client;      /* Server MQTT */
 
char *db_host;
char *db_name;
char *db_username;
char *db_password;

char *mqtt_host;
char *mqtt_username;
char *mqtt_password;


/*
 * Prototypes
 */
int on_message(void *, char *, int, MQTTClient_message *);
void msg_storage(char *, char *, int, int);
void print_help();
void setconfig();


/*
 * Main
 */
int 
main(int argc, char *argv[])
{
    int rc;
    int ch;
    int i;
    MQTTClient_connectOptions conn_opts = MQTTClient_connectOptions_initializer;


    /*
     * Check params
     */
    for ( i=1; i<argc; i++) {
        if ( strncmp(argv[i], help_param, sizeof(help_param)) == 0 ) {
            print_help();
            return 1;
        }

        if ( strncmp(argv[i], verbose_param, sizeof(verbose_param)) == 0 ) {
            verbose = 1;
        }

    }

    setconfig(); 


    /*
     * Show params
     */
    if ( verbose ) {
        printf("\nMQTT Settings\n");
        printf("Broker: %s\n", mqtt_host);

#ifdef DEBUG
        printf("Username: %s\n", mqtt_username);
        printf("Password: %s\n", mqtt_password);
#endif
        printf("\n");

        printf("PostgreSQL Settings\n");
        printf("Host: %s\n", db_host);
        printf("Name: %s\n", db_name);        
#ifdef DEBUG
        printf("Username: %s\n", db_username);
        printf("Password: %s\n", db_password);
#endif        
        
        printf("\n");
    }


    /* 
     * Init MQTT (conect & subscribe) 
     */
    rc = MQTTClient_create(&client, mqtt_host, MQTT_ID, MQTTCLIENT_PERSISTENCE_NONE, NULL);

    if ( rc != MQTTCLIENT_SUCCESS ) {
	    printf("Error on create MQTTClient, return code: %d\n", rc);
	    return 1;
    }

    conn_opts.keepAliveInterval = 20;
    conn_opts.cleansession = 1;
    conn_opts.username = mqtt_username;
    conn_opts.password = mqtt_password; 

    MQTTClient_setCallbacks(client, NULL, NULL, on_message, NULL);

    rc = MQTTClient_connect(client, &conn_opts);

    if (rc == MQTTCLIENT_SUCCESS) {
        printf("MQTT server connected!\n");
    } else {
        printf("Fail while connect subscriber, return code: %d\n", rc);
        return rc;
    }

    MQTTClient_subscribe(client, MQTT_TOPIC, MQTT_QOS);


    /*
     * Init Postgres (connect)
     */
    conn = do_connect(db_name, db_username, db_password, db_host);
 
    if ( conn ) {
        printf("PosgreSQL server Connected!\n");
    } else {
        printf("Fail while connect database\n");
        return 1;
    }


    /*
     * Loop waiting
     */
    printf("\nDaemon waiting for payload... \n");
   
    while (1) {       
        //if key press Q or ESC, break
        sleep(1);
    }

    do_exit(conn);
    return 0;
}


/*
 * Functions
 */
int 
on_message(void *context, char *topicName, int topicLen, MQTTClient_message *message) 
{
    char* payload = message->payload;
    int qos = message->qos;
    int retained = message->retained;

    if ( verbose ) {
        printf("Topic: %s\n", topicName);
        printf("Message: %s\n", payload);
        printf("QoS: %d\n", qos);
	    printf("Retained: %d\n", retained);
    }

    msg_storage(topicName, payload, qos, retained);

    MQTTClient_freeMessage(&message);
    MQTTClient_free(topicName);

    return 1;
}

void 
msg_storage(char *topic, char *payload, int qos, int retained)
{
    Thing *thing;
    Payload datum;
    int id_sensor;
    char uuid[LEN_UUID];

    if ( conn ) {
        sscanf(topic, "%36s/%d", uuid, &id_sensor);

#ifdef DEBUG
printf("[sscanf] %s\n", uuid);printf("[sscanf] %d\n", id_sensor);
#endif

        thing = get_thing_uuid(conn, uuid);
 
        if ( thing != NULL ) {
            strcpy(datum.payload, payload);
            datum.qos = qos;
	        datum.retained = retained;
            strcpy(datum.topic, topic); 

            if ( verbose ) {
                printf("\tUUID: %s\n", uuid);
                printf("\tSensor: %d\n", id_sensor);
                printf("\tPayload: %s\n", payload);
		        printf("\tQos: %d\n", qos);
		        printf("\tRetained: %d\n", retained);
                printf("\tTopic: %s\n", topic);
                printf("\n");
            }

            if ( !payload_insert(conn, &datum) ) {
                printf("Error while insert datum of sensor\n");    
            }
        }
    }
}

void 
print_help()
{
    printf("Usage: subscriber\n");
    printf("%s\tThis help\n", help_param);
    printf("%s\tMode Verbose\n", verbose_param);
}

void 
setconfig()
{
    const char env_mqtt_host[] = "MOSQUITTO_HOST";
    const char env_mqtt_user[] = "MOSQUITTO_USER";
    const char env_mqtt_passwd[] = "MOSQUITTO_PASSWORD";
    const char env_db_host[] = "POSTGRES_HOST";
    const char env_db_name[] = "POSTGRES_DB";
    const char env_db_user[] = "POSTGRES_USER";
    const char env_db_passwd[] = "POSTGRES_PASSWORD";

    int empty = 0;

    mqtt_host = getenv(env_mqtt_host);
    if ( !mqtt_host ) {
        printf("Empty environment: %s\n", env_mqtt_host);
        empty = 1;
    }

    mqtt_username = getenv(env_mqtt_user);
    if ( !mqtt_username ) {
        printf("Empty environment: %s\n", env_mqtt_user);
        empty = 1;
    }

    mqtt_password = getenv(env_mqtt_passwd);
    if ( !mqtt_password ) {
        printf("Empty environment: %s\n", env_mqtt_passwd);
        empty = 1;
    }

    db_host = getenv(env_db_host);
    if ( !db_host ) {
        printf("Empty environment: %s\n", env_db_host);
        empty = 1;
    }

    db_name = getenv(env_db_name);
    if ( !db_name ) {
        printf("Empty environment: %s\n", env_db_name);
        empty = 1;
    }

    db_username = getenv(env_db_user);
    if ( !db_username ) {
        printf("Empty environment: %s\n", env_db_user);
        empty = 1;
    }

    db_password = getenv(env_db_passwd);
    if ( !db_password ) {
        printf("Empty environment: %s\n", env_mqtt_passwd);
        empty = 1;
    }

    if ( empty ) {
        exit(1);
    }
}

