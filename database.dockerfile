FROM postgres:13.7

RUN apt-get update
RUN apt-get install -y postgresql-13-cron

COPY database/postgresql.conf /tmp/postgresql.conf
RUN cat /tmp/postgresql.conf >> /var/lib/postgresql/data/postgresql.conf
 
