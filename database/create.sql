--CREATE DATABASE IF NOT EXISTS sensoriando;
ALTER DATABASE sensoriando SET timezone TO 'UTC';

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_cron";

