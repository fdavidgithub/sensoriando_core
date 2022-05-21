# Create database structure

SQL=$(pwd)

CREATE=$SQL/create.sql
TABLES=$SQL/tables.sql
FUNCTIONS=$SQL/functions.sql
PROCEDURES=$SQL/procedures.sql
TRIGGERS=$SQL/triggers.sql
INSERTS=$SQL/inserts.sql
VIEWS=$SQL/views.sql

if [ -f init.sql ]; then
    rm init.sql
fi

touch init.sql

cat $CREATE     >> init.sql
cat $TABLES     >> init.sql
cat $VIEWS      >> init.sql
cat $INSERTS    >> init.sql
cat $PROCEDURES >> init.sql
cat $FUNCTIONS  >> init.sql
cat $TRIGGERS   >> init.sql
cat $CREATE     >> init.sql

