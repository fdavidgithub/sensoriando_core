# Create database structure
# Postgres native (no docker)
#!/bin/bash

export PSQL="psql -U postgres -d sensoriando"
export SQL=$(pwd)


#
# Functions
#
log() {
    LEVEL=$1
    MESSAGE=$2

    logger --priority local0.$LEVEL -t Sensoriando[$0] $MESSAGE
}

setdatabase() {
    CREATE=$SQL/create.sql
    TABLES=$SQL/tables.sql
    FUNCTIONS=$SQL/functions.sql
    PROCEDURES=$SQL/procedures.sql
    TRIGGERS=$SQL/triggers.sql
    INSERTS=$SQL/inserts.sql
    VIEWS=$SQL/views.sql

    log info "Create database... "
    createdb $DB_NAME
    psql -f $CREATE

    MSG="Creating tables from $TABLES"
    if [ -e $TABLES ]; then
        $PSQL -f $TABLES
	    log info $MSG
    else
        log error $MSG
    fi  

    MSG="Creating views from $VIEWS"
    if [ -e $VIEWS ]; then
        $PSQL -f $VIEWS
        log info $MSG
    else
        log error $MSG
    fi   

    MSG="Insert records from $INSERTS:"
    if [ -e $INSERTS ]; then
        $PSQL -f $INSERTS
        log info $MSG
    else
        log error $MSG
    fi   

    MSG="Creating procedures from $PROCEDURES"
    if [ -e $PRODECURES ]; then
        $PSQL -f $PROCEDURES
        log info $MSG
    else
        log error $MSG
    fi   

    MSG="Creating functions from $FUNCTIONS"
    if [ -e $FUNCTIONS ]; then
        $PSQL -f $FUNCTIONS
        log info $MSG
    else
        log error $MSG
    fi   

    MSG="Creating triggers from $TRIGGERS"
    if [ -e $TRIGGERS ]; then
        $PSQL -f $TRIGGERS
	    log info $MSG
    else
        log error $MSG
    fi   
}

# 
# Main script
#
setdatabase

exit 0

