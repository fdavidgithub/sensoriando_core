# Create database structure
# Postgres native (no docker)
#!/bin/bash
source ../.env

export DOCKER=$1
export FAIL=1
export SUCCESS=0
export PREFIX=""
export SQL_DIR=$(pwd)


if [ -n $DOCKER ]; then
    export PREFIX="docker exec -it $DOCKER"
    export SQL_DIR="/"

    for file in *.sql; do
        docker cp "$file" $DOCKER:/
    done
fi

export PSQL="$PREFIX psql -U $POSTGRES_USER -d $POSTGRES_DB"

#
# Functions
#
log() {
    LEVEL=$1
    MESSAGE=$2
    
    echo "[$LEVEL] $MESSAGE"
    logger --priority local0.$LEVEL -t Sensoriando[$0] $MESSAGE
}

database() {
    CREATE=$SQL_DIR/create.sql
    
    log info "Create database... "
    if [ -n $DOCKER ]; then
        docker exec -it $DOCKER createdb -U $POSTGRES_USER $POSTGRES_DB
    else
        createdb -U $POSTGRES_USER $POSTGRES_DB
    fi

    $PSQL -f $CREATE
}

db-tables() {
    TABLES=$SQL_DIR/tables.sql
    MSG="Creating tables from $TABLES"
    
    $PSQL -f $TABLES
	if [ $? -ne 0 ]; then
        log error $MSG
        exit $FAIL
    fi

    log info $MSG
}

db-views() {
    VIEWS=$SQL_DIR/views.sql
    MSG="Creating views from $VIEWS"

    $PSQL -f $VIEWS
    if [ $? -ne 0 ]; then
        log error $MSG
        exit $FAIL
    fi 

    log info $MSG
}

db-functions() {
    FUNCTIONS=$SQL_DIR/functions.sql
    MSG="Creating functions from $FUNCTIONS"
 
    $PSQL -f $FUNCTIONS
    if [ $? -ne 0 ]; then
        log error $MSG
        exit $FAIL
    fi 

    log info $MSG
}

db-procedures() {
    PROCEDURES=$SQL_DIR/procedures.sql
    MSG="Creating procedures from $PROCEDURES"

    $PSQL -f $PROCEDURES
    if [ $? -ne 0 ]; then
        log error $MSG
        exit $FAIL
    fi 

    log info $MSG
}

db-triggers() {
    TRIGGERS=$SQL_DIR/triggers.sql
    MSG="Creating triggers from $TRIGGERS"
 
    $PSQL -f $TRIGGERS
    if [ $? -ne 0 ]; then
        log error $MSG
        exit $FAIL
    fi 

    log info $MSG
}

db-inserts() {
    INSERTS=$SQL_DIR/inserts.sql
    MSG="Insert records from $INSERTS:"
 
    $PSQL -f $INSERTS
    if [ $? -ne 0 ]; then
        log error $MSG
        exit $FAIL
    fi 

    log info $MSG
}

# 
# Main script
#
schedule=()
schedule+=(database)
schedule+=(db-tables)
schedule+=(db-views)
schedule+=(db-procedures)
schedule+=(db-functions)
schedule+=(db-triggers)
schedule+=(db-inserts)

for execFunc in "${schedule[@]}"; do
    $execFunc
done

exit $SUCCESS


